export class GasOptimizer {
    static async getOptimalGasParams(
      provider: ethers.providers.Provider
    ): Promise<{
      maxFeePerGas: ethers.BigNumber;
      maxPriorityFeePerGas: ethers.BigNumber;
    }> {
      const [block, feeData] = await Promise.all([
        provider.getBlock('latest'),
        provider.getFeeData(),
      ]);
  
      // 动态计算优先费 (EIP-1559)
      const baseFee = block.baseFeePerGas || ethers.BigNumber.from(0);
      const priorityFee = feeData.maxPriorityFeePerGas || 
        ethers.BigNumber.from(1_500_000_000); // 1.5 Gwei默认值
  
      // 预测下一区块基础费
      const nextBaseFee = this.calculateNextBaseFee(block);
      
      return {
        maxFeePerGas: nextBaseFee.add(priorityFee),
        maxPriorityFeePerGas: priorityFee,
      };
    }
  
    private static calculateNextBaseFee(block: ethers.providers.Block): ethers.BigNumber {
      const gasUsed = block.gasUsed;
      const gasLimit = block.gasLimit;
      const baseFee = block.baseFeePerGas || ethers.BigNumber.from(0);
      
      // 简化版EIP-1559基础费计算
      const delta = gasUsed.mul(8).div(10).sub(gasLimit.div(2));
      return baseFee.add(baseFee.mul(delta).div(gasLimit).div(8));
    }
  }