import Web3 from "web3";
import EPDebtCrafter from "./contracts/EPDebtCrafter.json";
import EPDebtNFT from "./contracts/EPDebtNFT.json";

const options = {
  // web3: {
  //   block: false,
  //   customProvider: new Web3(Web3.givenProvider || "ws://localhost:8545"),
  // },
  contracts: [EPDebtCrafter, EPDebtNFT],
  events: {
    EPDebtNFT: ["TransferSingle"],
  },
};

export default options;
