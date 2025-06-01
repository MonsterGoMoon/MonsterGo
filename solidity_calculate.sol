pragma solidity ^0.8.19;
import "@eth-optimism/contracts/L1/messaging/IL1StandardBridge.sol";

contract PumpL1Bridge {
    // 使用位运算加速数学计算
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    //将多个小变量打包到单个bytes32
    function verifyBatch(
        bytes32 rootHash,
        bytes32[] memory proof,
        uint256 index,
        address sender,
        uint256 amount
    ) public pure returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(index, sender, amount));
        return MerkleProof.verify(proof, rootHash, leaf);
    }
}
