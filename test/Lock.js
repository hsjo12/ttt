const {ethers} = require("hardhat");
const { expect } = require("chai");
describe("TEST",()=>{




  it("TEST", async()=>{
    
    const owner = await ethers.getImpersonatedSigner("0x367AE3ED8c21121c406FEb8F7b19B627B8AE7c3c");
    const SORTED_PROPOSAL_ADDRESS = "0x66e84B93572D7b6f006e3B079CBa756E3724de3c";
    const SORTED_QUEUE_AND_EXECUTION = "0xb30811AE90b9D9d377F71321627B7e00af7b15dd";
    const PROPOSAL_LIST_UP_KEEP = "0xcae0F30234b8495234bD76A84f40daA5f107cF71";
    const QUEUE_AND_EXECUTION_LIST_UP_KEEP = "0x8A2136dffF04Febd6E37321b00dc8DF226bE82aD";
    const PROFITNFT = "0xEBD1B300EE65b614E7f403dd9e3Ad7967728CeA6";
  
    await console.log(owner.address)
    await console.log(owner.address)
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
    const DEFAULT_ADMIN_ROLE = ethers.constants.HashZero;
    const proposerList = [];
    const executorList = [ethers.constants.AddressZero];
  
    const GovernanceNFT = await ethers.getContractFactory("GovernanceNFTs");
    const governanceNFT = await GovernanceNFT.connect(owner).deploy();
    await governanceNFT.deployed();
  
    const GovernanceTimeLock = await ethers.getContractFactory("GovernanceTimeLock");
    const governanceTimeLock = await GovernanceTimeLock.connect(owner).deploy(TIMELOCK_MIN_DELAY, proposerList, executorList, owner.address);
    await governanceTimeLock.deployed();
  
    const GovernorContract = await ethers.getContractFactory("GovernorContract");
    const governorContract = await GovernorContract.connect(owner).deploy(DAO_NAME, governanceNFT.address, governanceTimeLock.address, GOVERNANCE_VOTING_DELAY, GOVERNANCE_VOTING_PERIOD, GOVERNANCE_QUORUM_PERCENTAGE);
    await governorContract.deployed();
  
    const TargetContract = await ethers.getContractFactory("TargetContract");
    const targetContract = await TargetContract.connect(owner).deploy();
    await targetContract.deployed();
  
    const sortedProposal = await ethers.getContractAt("SortedProposalList", SORTED_PROPOSAL_ADDRESS);
    const sortedQueue = await ethers.getContractAt("SortedQueueAndExecutionList", SORTED_QUEUE_AND_EXECUTION);
    
    const DaoFactory = await ethers.getContractFactory("DaoFactory");
    const daoFactory = await DaoFactory.connect(owner).deploy(governanceNFT.address, governanceTimeLock.address, governorContract.address, SORTED_PROPOSAL_ADDRESS, SORTED_QUEUE_AND_EXECUTION);
    await console.log(network.config.chainId)
    await console.log(network.config.chainId)
    await console.log(network.config.chainId)

    
    const tx = await sortedProposal.connect(owner).grantRole(DEFAULT_ADMIN_ROLE, daoFactory.address);
    await tx.wait(); 
    const tx2 = await sortedQueue.connect(owner).grantRole(DEFAULT_ADMIN_ROLE, daoFactory.address);
    await tx2.wait();
  
    const result = await sortedProposal.hasRole(DEFAULT_ADMIN_ROLE, daoFactory.address);
   

   await daoFactory.connect(owner).create([   
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

    console.log(vote)
    console.log(timelock)
    console.log(dao);

    const governorInstance = await ethers.getContractAt("GovernorContract", dao);
    const governanceNFTsInstance = await ethers.getContractAt("GovernanceNFTs", vote);
    await governanceNFTsInstance.connect(owner).adminMint(owner.address, 100);
    governanceTimeLock.connect(owner).grantRole(governanceTimeLock.PROPOSER_ROLE(), (governorInstance));
   
   
  

    const targets = [targetContract.address];
    const values = [0];

    const iface = new ethers.utils.Interface([
      "function setValue(uint256 _value)",
    ]);
    const calldatas = [iface.encodeFunctionData("setValue", [55])];

    const description = "NIKE JAKECT SHOULD BE LISTED ON SHAOPDAO";
    const descriptionHash = ethers.utils.keccak256(
      ethers.utils.toUtf8Bytes(description)
    );

    await governanceNFTsInstance.connect(owner).delegate(owner.address);
    const proposalId = await governorInstance.connect(owner).propose(targets, values, calldatas, description);
    console.log(proposalId)
   
    // // uint8 opinion = 1; // 0 = no, 1 = yes, 2 = giving up
    // // governorInstance.castVote(proposalId, opinion);
  })

 



})