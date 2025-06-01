pragma solidity ^0.8.19;
import "@eth-optimism/contracts/L2/messaging/L2CrossDomainMessenger.sol";

contract BatchProcessor {
    L2CrossDomainMessenger public immutable MESSENGER;
    uint256 public constant MAX_BATCH_SIZE = 100;

    constructor(address messenger) {
        MESSENGER = L2CrossDomainMessenger(messenger);
    }

    function batchTransfer(
        address token,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        require(recipients.length == amounts.length, "Length mismatch");
        require(recipients.length <= MAX_BATCH_SIZE, "Batch too large");

        for (uint i = 0; i < recipients.length; i++) {
            IERC20(token).transferFrom(msg.sender, recipients[i], amounts[i]);
        }
    }

    // 跨链消息批量处理
    function processMessages(bytes[] calldata messages) external {
        for (uint i = 0; i < messages.length; i++) {
            (bool success, ) = address(MESSENGER).call(messages[i]);
            require(success, "Message failed");
        }
    }
}
