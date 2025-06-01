pragma solidity ^0.8.19;
import "@eth-optimism/contracts/L1/messaging/IL1StandardBridge.sol";

contract PumpL1Bridge {
    IL1StandardBridge public constant BRIDGE =
        IL1StandardBridge(0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1);

    function depositToken(
        address l1Token,
        address l2Token,
        uint256 amount,
        uint32 l2Gas
    ) external payable {
        IERC20(l1Token).transferFrom(msg.sender, address(this), amount);
        IERC20(l1Token).approve(address(BRIDGE), amount);

        BRIDGE.depositERC20To(l1Token, l2Token, msg.sender, amount, l2Gas, "");
    }
}
