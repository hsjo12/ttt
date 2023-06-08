// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/** 
 * @title IGoveranceNFTs 
 */
interface IGoveranceNFTs {
    /**
     * @notice The init function is to set up values in the constructor of inherited contracts required for GovernanceNFTs.
     * @dev It is only executed only once right after clonning GovernanceNFTs. 
     * @param _owner is the owner of a NFT.
     * @param _maximumSupply is the maximum number of a NFT.
     * @param _price is the _price of a NFT.
     * @param _name is the name of a NFT.
     * @param _symbol is the symbol of a NFT.
     * @param _shopDaoBaseURI  is URI of a NFT.
     */
    function init(
        address _owner,
        uint256 _maximumSupply,
        uint256 _price,
        string calldata _name, 
        string calldata _symbol, 
        string calldata _shopDaoBaseURI
    ) 
        external;
}