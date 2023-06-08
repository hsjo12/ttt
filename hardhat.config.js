require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10000,
      },
    },
  },
  // gasReporter: {
  //   currency: "ETH",
  //   enabled: true,
  //   coinmarketcap: "8c73ee1a-5579-43a3-8e29-52893c5ecb00",
  // },
  networks: {
    hardhat: {
      forking: {
        url: "https://polygon-mumbai.g.alchemy.com/v2/_uOWdh3oSVyEculEiL5MbBzyeIc4jnms",
      },
    },
    polygon: {
      url: "https://polygon-mainnet.g.alchemy.com/v2/BpWT_42Q4nAEPoOGPUYQJahp5T18Cwd2",
      chainId: 137,
      // accounts: [process.env.MY_PRIVATE_TEST_KEY_POLYGON],
      accounts: [process.env.MY_PRIVATE_KEY],
      gasPrice: 200000000000,
    },
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/9qgg-hwK-lCfM2rhUdWwesop9ez3A7IN",
      chainId: 80001,
      accounts: [process.env.MY_PRIVATE_KEY],
    },
    sepolia: {
      url:  "https://eth-sepolia.g.alchemy.com/v2/R-Qe3PMI1u_wPw7fHubHnKWVBYmJGmFG",
      chainId: 11155111,
      accounts: [process.env.MY_PRIVATE_KEY],
    },
   
  },
  mocha: {
    timeout: 4000000,
  },
}