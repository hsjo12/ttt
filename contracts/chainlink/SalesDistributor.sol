// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../node_modules/erc721a/contracts/extensions/IERC721AQueryable.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ISalesDistributor.sol";
contract SalesDistributor is Ownable, ISalesDistributor, AccessControl {
    
    /// Immutable
    address public immutable USDC_ADDRESS;
    IERC20 public immutable USDC;

    /// Constant
    bytes32 public constant BRAND_MANAGER_ROLE = keccak256("BRAND_MANAGER_ROLE");
    uint256 public constant BPS = 10_000;

    /// Error 
    error ItemIsNotSold();
    error InsufficientBalance();

    // todo: to IFChainlinkAutomatedFunction
    address public salesDistributorClient;

    modifier onlySalesDistributorClient() {
        require(msg.sender == salesDistributorClient, "Caller is not the sales distributor client");
        _;
    }

    // salesDistributorClient is executed by automation of ChainlinkFunctions.
    constructor(address _salesDistributorClient, address _usdcAddress) {
        salesDistributorClient = _salesDistributorClient;
        USDC_ADDRESS = _usdcAddress;
        USDC = IERC20(USDC_ADDRESS);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(BRAND_MANAGER_ROLE, msg.sender);
    }

    // For storing total sales for each NFT address
    mapping(address => uint256) public totalDistributedSales;
    mapping(address => uint256) public totalDistributedProfit;
    mapping(address => bool) public isSoldByNFTaddress;

    mapping(address => uint256) public totalClaimedToken;
    mapping(address => mapping(address => uint256)) public userClaimedProfits;
    mapping(address => mapping(uint256 => bool)) public isNftIdUsed;
 

    event ProfitsDistributed(address indexed nftAddress, string orderId, uint256 totalSale, uint256 totalProfit);
    event Claim(address indexed user, uint256 claimedProfit);

    function claimCondition(DistributionDetails calldata distributionDetails) public onlySalesDistributorClient {
        totalDistributedSales[distributionDetails.nftAddress] += distributionDetails.totalSale;
        totalDistributedProfit[distributionDetails.nftAddress] += distributionDetails.totalProfit;
        isSoldByNFTaddress[distributionDetails.nftAddress] = true; 
        USDC.transferFrom(msg.sender, address(this), distributionDetails.totalProfit);
        emit ProfitsDistributed(distributionDetails.nftAddress, distributionDetails.orderId, distributionDetails.totalSale, distributionDetails.totalProfit);
    }
    
    function claim(address _nftAddress) external {
        if(!isSoldByNFTaddress[_nftAddress]) revert ItemIsNotSold();
        if(USDC.balanceOf(address(this)) < (totalDistributedProfit[_nftAddress] - totalClaimedToken[_nftAddress])) revert InsufficientBalance();
        IERC721AQueryable nft = IERC721AQueryable(_nftAddress);
        uint256 totalNumOfNft = nft.totalSupply();
        uint256[] memory ownedNFTListOf = nft.tokensOfOwner(msg.sender);
        uint256 totalNumOfOwnedToken = ownedNFTListOf.length;
        mapping(uint256 => bool) storage _isNftIdUsed = isNftIdUsed[_nftAddress];
        uint256 alreadyUsedToken = 0;
        for(uint256 i = 0; i < totalNumOfOwnedToken; ++i) {
            if(_isNftIdUsed[ownedNFTListOf[i]]) {
                alreadyUsedToken += 1;
            }else{
                _isNftIdUsed[ownedNFTListOf[i]] = true;
            }
           
        }
        uint256 totalNumOfOwnedNotUsedToken = totalNumOfOwnedToken - alreadyUsedToken;
        uint256 totalNFTPecentageOfUserInBPS = (totalNumOfOwnedNotUsedToken * BPS) / totalNumOfNft;
        uint256 totalUserProfitsToClaim = (totalDistributedProfit[_nftAddress] * totalNFTPecentageOfUserInBPS) / BPS; 
        userClaimedProfits[_nftAddress][msg.sender] += totalUserProfitsToClaim;
        totalClaimedToken[_nftAddress] += totalUserProfitsToClaim;
        USDC.transfer(msg.sender, totalUserProfitsToClaim);
        emit Claim(msg.sender, totalUserProfitsToClaim);
    }

    function getDistributionByNftAddress(address _nftAddress) public view returns (uint256,uint256) {
        return (totalDistributedSales[_nftAddress], totalDistributedProfit[_nftAddress]);
    }

    function getUserProfit(address _nftAddress, address _userAddress) public view returns (uint256) {
        IERC721AQueryable nft = IERC721AQueryable(_nftAddress);
        uint256 totalNumOfNft = nft.totalSupply();
        uint256[] memory ownedNFTListOf = nft.tokensOfOwner(_userAddress);
        uint256 totalNumOfOwnedToken = ownedNFTListOf.length;
        uint256 alreadyUsedToken = 0;
        mapping(uint256 => bool) storage _isNftIdUsed = isNftIdUsed[_nftAddress];
        for(uint256 i = 0; i < totalNumOfOwnedToken; ++i) {
            if(_isNftIdUsed[ownedNFTListOf[i]]) {
                alreadyUsedToken += 1;
            }
        }
        uint256 totalNumOfOwnedNotUsedToken = totalNumOfOwnedToken - alreadyUsedToken;
        uint256 totalNFTPecentageOfUserInBPS = (totalNumOfOwnedNotUsedToken * BPS) / totalNumOfNft;
        uint256 totalUserProfitsToClaim = (totalDistributedProfit[_nftAddress] * totalNFTPecentageOfUserInBPS) / BPS; 

        return totalUserProfitsToClaim;
    }

    function withdrawProfit(
        address _nftAddress
    ) 
        external 
        onlyRole(BRAND_MANAGER_ROLE)  
    {
       uint256 currentUSDCByNFT = totalDistributedProfit[_nftAddress] - totalClaimedToken[_nftAddress];
       USDC.transfer(msg.sender, currentUSDCByNFT);
    }

    //　This function is not needed in production. For decentralization autonomous
    function setSalesDistributorClient(address _salesDistributorClient)
        external 
        onlyRole(BRAND_MANAGER_ROLE) 
    {
        salesDistributorClient = _salesDistributorClient;
    }
}
