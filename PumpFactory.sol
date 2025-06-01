// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/utils/Clones.sol";

contract PumpFactory {
    using Clones for address;

    address public immutable masterToken;
    uint256 public createFee = 0.1 ether;
    mapping(address => address[]) public userTokens;

    event TokenCreated(address indexed creator, address token);

    constructor(address _masterToken) {
        masterToken = _masterToken;
    }

    function createToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 auctionDuration
    ) external payable returns (address) {
        require(msg.value >= createFee, "Insufficient fee");

        address token = masterToken.clone();
        IPumpToken(token).initialize(
            msg.sender,
            name,
            symbol,
            initialSupply,
            auctionDuration
        );

        userTokens[msg.sender].push(token);
        emit TokenCreated(msg.sender, token);
        return token;
    }

    function setCreateFee(uint256 fee) external onlyOwner {
        createFee = fee;
    }
}
