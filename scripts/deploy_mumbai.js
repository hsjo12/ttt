// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require("fs");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {



  const SORTED_PROPOSAL_ADDRESS = "0x66e84B93572D7b6f006e3B079CBa756E3724de3c";
  const SORTED_QUEUE_AND_EXECUTION = "0xb30811AE90b9D9d377F71321627B7e00af7b15dd";
  const PROPOSAL_LIST_UP_KEEP = "0xcae0F30234b8495234bD76A84f40daA5f107cF71";
  const QUEUE_AND_EXECUTION_LIST_UP_KEEP = "0x8A2136dffF04Febd6E37321b00dc8DF226bE82aD";
  const PROFITNFT = "0xEBD1B300EE65b614E7f403dd9e3Ad7967728CeA6";
  

  const [owner] = await hre.ethers.getSigners();


  const DAO_NAME = "Suprem3 DAO";
  const MAXIMUM_SUPPLY = 10000;
  const VOTE_PRICE = 0;
  const VOTE_NAME = "GRAND OPENING VOTES";
  const VOTE_SYMBOL = "GOV";
  const VOTE_URI = "ipfs://metadata.json";
  const TIMELOCK_MIN_DELAY = 50; /// block.timestamp
  const GOVERNANCE_VOTING_DELAY = 0;
  const GOVERNANCE_VOTING_PERIOD = 1000; /// block.number
  const GOVERNANCE_QUORUM_PERCENTAGE = 1; /// 100 %
  const DEFAULT_ADMIN_ROLE = hre.ethers.constants.HashZero;
  const proposerList = [];
  const executorList = [hre.ethers.constants.AddressZero];

  const GovernanceNFT = await hre.ethers.getContractFactory("GovernanceNFTs");
  const governanceNFT = await GovernanceNFT.deploy();
  await governanceNFT.deployed();

  const GovernanceTimeLock = await hre.ethers.getContractFactory("GovernanceTimeLock");
  const governanceTimeLock = await GovernanceTimeLock.deploy(TIMELOCK_MIN_DELAY, proposerList, executorList, owner.address);
  await governanceTimeLock.deployed();

  const GovernorContract = await hre.ethers.getContractFactory("GovernorContract");
  const governorContract = await GovernorContract.deploy(DAO_NAME, governanceNFT.address, governanceTimeLock.address, GOVERNANCE_VOTING_DELAY, GOVERNANCE_VOTING_PERIOD, GOVERNANCE_QUORUM_PERCENTAGE);
  await governorContract.deployed();

  const TargetContract = await hre.ethers.getContractFactory("TargetContract");
  const targetContract = await TargetContract.deploy();
  await targetContract.deployed();

  const sortedProposal = await hre.ethers.getContractAt("SortedProposalList", SORTED_PROPOSAL_ADDRESS);
  const sortedQueue = await hre.ethers.getContractAt("SortedQueueAndExecutionList", SORTED_QUEUE_AND_EXECUTION);
  
  const DaoFactory = await hre.ethers.getContractFactory("DaoFactory");
  const daoFactory = await DaoFactory.deploy(governanceNFT.address, governanceTimeLock.address, governorContract.address, SORTED_PROPOSAL_ADDRESS, SORTED_QUEUE_AND_EXECUTION);
  const chainId = hre.network.config.chainId;
  

  CreateJs(targetContract, "TargetContract", chainId);
  CreateJs(governanceNFT, "GovernanceNFTs", chainId);
  CreateJs(governanceTimeLock, "GovernanceTimeLock", chainId);

  CreateJs(daoFactory, "DaoFactory", chainId);
  
  const tx = await sortedProposal.grantRole(DEFAULT_ADMIN_ROLE, daoFactory.address);
  await tx.wait(); 
  const tx2 = await sortedQueue.grantRole(DEFAULT_ADMIN_ROLE, daoFactory.address);
  await tx2.wait();


 await daoFactory.create([   
    DAO_NAME, 
    owner.address, 
    MAXIMUM_SUPPLY, 
    VOTE_PRICE,
    VOTE_NAME, 
    VOTE_SYMBOL, 
    VOTE_URI,    
    TIMELOCK_MIN_DELAY,
    GOVERNANCE_VOTING_DELAY,
    GOVERNANCE_VOTING_PERIOD,
    GOVERNANCE_QUORUM_PERCENTAGE]);

    const {name, vote, timelock, dao, createTime} = await daoFactory.connect(owner).daoStorage(1);
    const governorInstance = await ethers.getContractAt("GovernorContract", dao);
    const governanceNFTsInstance = await ethers.getContractAt("GovernanceNFTs", vote);
    // await governanceNFTsInstance.connect(owner).adminMint(owner.address, 100);
    governanceTimeLock.connect(owner).grantRole(governanceTimeLock.PROPOSER_ROLE(), (governorInstance));
    
    

}

const CreateJs = async (contract, text, chainId) => {
  const chainId_ = hre.network.config.chainId;
  console.log(chainId_);
  console.log(text, contract.address);
  const artiPath = path.join(__dirname, "../frontend/src/abis");

  if (!fs.existsSync(artiPath)) {
    fs.mkdirSync(artiPath, { recursive: true });
  }

  const artifacts = await hre.artifacts.readArtifact(text);
  // console.log(artifacts);
  artifacts.networkId = chainId;
  artifacts.address = contract.address;

  fs.writeFileSync(
    artiPath + `/${text}.json`,
    JSON.stringify(artifacts, null, 2)
  );
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
