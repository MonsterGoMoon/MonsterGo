pragma solidity ^0.8.19;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract PumpToken is ERC20Upgradeable {
    struct AuctionParams {
        uint256 startTime;
        uint256 endTime;
        uint256 startPrice;
        uint256 reservePrice;
    }

    AuctionParams public auction;
    address public factory;
    uint256 public taxRate;

    function initialize(
        address creator,
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 auctionDuration
    ) external initializer {
        __ERC20_init(name, symbol);
        _mint(creator, initialSupply);

        auction = AuctionParams({
            startTime: block.timestamp,
            endTime: block.timestamp + auctionDuration,
            startPrice: 1 ether,
            reservePrice: 0.1 ether
        });

        factory = msg.sender;
        taxRate = 5; // 5%
    }

    function currentPrice() public view returns (uint256) {
        uint256 elapsed = block.timestamp - auction.startTime;
        uint256 duration = auction.endTime - auction.startTime;
        if (elapsed >= duration) return auction.reservePrice;

        return
            auction.startPrice -
            (elapsed * (auction.startPrice - auction.reservePrice)) /
            duration;
    }

    // Gas优化版transfer
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 tax = (amount * taxRate) / 100;
        _transfer(_msgSender(), address(this), tax);
        _transfer(_msgSender(), to, amount - tax);
        return true;
    }

    // 使用EIP-712签名验证
    function permitTransfer(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(block.timestamp <= deadline, "Expired");
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                ),
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline
            )
        );
        address signer = ECDSA.recover(_hashTypedDataV4(structHash), v, r, s);
        require(signer == owner, "Invalid signature");
        _approve(owner, spender, value);
    }
}
