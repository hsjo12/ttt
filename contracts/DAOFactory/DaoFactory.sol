// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../../node_modules/@openzeppelin/contracts/proxy/Clones.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/governance/utils/IVotes.sol";
import "../interfaces/IDaoFactory.sol";
import "../interfaces/IGoveranceNFTs.sol";
import "../interfaces/IGovernanceTimeLock.sol";
import "../interfaces/IGovernorContract.sol";
import "../interfaces/ISortedList.sol";
import "hardhat/console.sol";
/** 
 * @title DaoFactory
 * @notice Only brand managers can use DaoFactory to create a new dao. 
 */
contract DaoFactory is AccessControl, IDaoFactory {

    ///Constant
    bytes32 public constant BRAND_MANAGER_ROLE = keccak256("BRAND_MANAGER_ROLE");

    /// Immutable
    address public immutable VOTE_ADDRESS; 
    address public immutable TIMELOCK_ADDRESS; 
    address public immutable DAO_ADDRESS; 
    ISortedList public immutable sortedProposalList;
    ISortedList public immutable sortedQueueAndExecutionList;

    /// Event
    event Create(uint256 indexed id, string name, address dao, address vote, uint256 createdTime);

    /// Varaable
    struct DAO {
        string name;
        address vote;
        address timelock;
        address dao;
        uint256 createdTime;
    }
   
    mapping(uint256 => DAO) public daoStorage; 
    uint256 public id = 1;
    address[] public proposerList;
    address[] public executorList = [address(0)];

    constructor(
        address _vote_address, 
        address _timeLock_address, 
        address _dao_address,
        address _sortedProposalList,
        address _sortedQueueAndExecutionList
    ) {
        VOTE_ADDRESS = _vote_address;
        TIMELOCK_ADDRESS = _timeLock_address;
        DAO_ADDRESS = _dao_address;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(BRAND_MANAGER_ROLE, msg.sender);
        sortedProposalList = ISortedList(_sortedProposalList);
        sortedQueueAndExecutionList = ISortedList(_sortedQueueAndExecutionList);
    }

    /**
     * @notice Only brand Managers can execute this function to create a new dao.
     * @dev  The "create" function is to clone goveranceNFTs, governanceTimeLock, and govornorContract. 
     * @param params is the parameter defined in IDaoFactory and is for cloning goveranceNFTs, governanceTimeLock, and govornorContract.
     */
    function create(createParams calldata params) 
        external 
        onlyRole(BRAND_MANAGER_ROLE) 
    {
     
        address vote = Clones.clone(VOTE_ADDRESS);
        address timeLock = Clones.clone(TIMELOCK_ADDRESS);
        address dao = Clones.clone(DAO_ADDRESS);
   
        AccessControl(address(sortedProposalList)).grantRole(BRAND_MANAGER_ROLE, dao);
        AccessControl(address(sortedQueueAndExecutionList)).grantRole(BRAND_MANAGER_ROLE, dao);
        

        daoStorage[id] = (DAO(params.daoName, vote, timeLock, dao, block.timestamp));

        IGoveranceNFTs(vote).init(
            params.owner, 
            params.voteMaximumSupply, 
            params.votePrice,
            params.voteName, 
            params.voteSymbol, 
            params.voteURI
        );

        IGovernanceTimeLock(timeLock).init(
            params.timelockMinDelay, 
            proposerList, 
            executorList, 
            params.owner
        );

        IGovernorContract(dao).init(
            params.daoName, 
            IVotes(vote), 
            TimelockController(payable(timeLock)), 
            params.governanceVotingDelay, 
            params.governanceVotingPeriod, 
            params.governanceQuorumPercentage, 
            params.owner,
            address(sortedProposalList),
            address(sortedQueueAndExecutionList)
        );

        emit Create(id++, params.daoName, dao, vote, block.timestamp);
   
    }

    /**
     * @notice The fetchDaoStoage will return the list of create daos.
     */
    function fetchDaoStoage() external view returns (DAO[] memory daolist) {
        uint256 size = id - 1;
        mapping(uint256=> DAO) storage _daostorage = daoStorage;
        daolist = new DAO[](size); 
        for(uint256 i = 0; i < size; ++i) {
            daolist[i] = _daostorage[i];
        }
    }
}