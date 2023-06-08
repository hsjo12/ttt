// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../node_modules/erc721a/contracts/extensions/ERC721AQueryable.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";


contract Profit is ERC721AQueryable, AccessControl {
    ///Constant
    bytes32 public constant BRAND_MANAGER_ROLE = keccak256("BRAND_MANAGER_ROLE");

    /// Error
    error ExceedsMaximumSupply();
    error AlreadyInitialized();

    /// Variable
    uint256 public tokenId;
    uint256 public maximumSupply;
    string private name_;
    string private symbol_;
    address public owner;
    string public shopDaoBaseURI;

    constructor() ERC721A("ShopDao", "ShopDao") {}

    /**
     * @notice The init function is to set up values in the constructor of inherited contracts required for GovernanceNFTs.
     * @dev It is only executed only once right after clonning GovernanceNFTs. 
     * @param _owner is the owner of a NFT.
     * @param _maximumSupply is the maximum number of a NFT.
     * @param _name is the name of a NFT.
     * @param _symbol is the symbol of a NFT.
     * @param _profitURI  is URI of a NFT.
     */
     function init(
        address _owner,
        uint256 _maximumSupply,
        string calldata _name, 
        string calldata _symbol, 
        string calldata _profitURI
    ) 
        external 
    {
        if(owner != address(0)) revert AlreadyInitialized();
        tokenId = 1;
        maximumSupply = _maximumSupply;
        name_ = _name;
        symbol_ = _symbol;
        owner = _owner;
        shopDaoBaseURI = _profitURI;
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(BRAND_MANAGER_ROLE, _owner);            
    }

    /**
     * @notice The mint function is to mint NFTs.
     * @dev The address having only the BRAND_MANAGER_ROLE role can execute it. 
     * @param _to is the address who receives minted NFTs.
     * @param _quantity is the number of NFTs to mint.
     */
     function mint(address _to, uint256 _quantity) external onlyRole(BRAND_MANAGER_ROLE) {
        if(maximumSupply < _totalMinted() + _quantity ) revert ExceedsMaximumSupply();
        _safeMint(_to, _quantity, "");
    }
    
    /**
     * @notice The setShopBaseURI function returns URI.
     * @dev The address having only the BRAND_MANAGER_ROLE role can execute it. 
     * @param _shopDaoBaseURI is the URI of a NFT.
     */
     function setShopBaseURI(string calldata _shopDaoBaseURI) external onlyRole(BRAND_MANAGER_ROLE) {
        shopDaoBaseURI = _shopDaoBaseURI;
    }
    
    /**
     * @notice The setOwner function changes the current owner.
     * @dev The address having only the BRAND_MANAGER_ROLE role can execute it. 
     * @param _owner the address of a new owner.
     */
     function setOwner(address _owner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        owner = _owner;
    }

    /**
     * @notice The tokenURI function returns the URI of a NFT.
     * @param _tokenId is the NFT Id you want to find the URI for.
     */
     function tokenURI(uint256 _tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();

        return bytes(shopDaoBaseURI).length != 0 ? shopDaoBaseURI : '';
    }

    function supportsInterface(bytes4 interfaceId) 
        public 
        view 
        override(AccessControl, ERC721A, IERC721A) 
        returns (bool) 
    {
        return super.supportsInterface(interfaceId);
    }
}
