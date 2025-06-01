const { Web3 } = require('web3');
const { Kafka } = require('kafkajs');

class EventMonitor {
  constructor(web3Provider, kafkaConfig) {
    this.web3 = new Web3(web3Provider);
    this.kafka = new Kafka(kafkaConfig);
    this.producer = this.kafka.producer();
  }

  async monitorContract(contractAddress, abi) {
    const contract = new this.web3.eth.Contract(abi, contractAddress);
    
    contract.events.allEvents({})
      .on('data', async (event) => {
        await this.producer.send({
          topic: 'contract-events',
          messages: [{
            value: JSON.stringify({
              block: event.blockNumber,
              tx: event.transactionHash,
              event: event.event,
              args: event.returnValues
            })
          }]
        });
      })
      .on('error', console.error);
  }
}