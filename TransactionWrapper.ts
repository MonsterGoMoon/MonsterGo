import { ethers } from 'ethers';
import { Biconomy } from '@biconomy/mexa';

export class GaslessTransactionSender {
  private biconomy: Biconomy;
  
  constructor(provider: any, biconomyApiKey: string) {
    this.biconomy = new Biconomy(provider, { apiKey: biconomyApiKey });
  }

  async sendGaslessTransaction(
    contract: ethers.Contract,
    method: string,
    params: any[],
    signature?: string
  ): Promise<ethers.providers.TransactionResponse> {
    const txParams = {
      data: contract.interface.encodeFunctionData(method, params),
      to: contract.address,
      signature: signature,
    };

    return this.biconomy.sendTransaction(txParams);
  }
}