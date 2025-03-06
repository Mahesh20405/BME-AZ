require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.5.1",
  networks: {
    hardhat: {},
    localhost: {
      url: "http://127.0.0.1:8545", 
    },
  },
};
