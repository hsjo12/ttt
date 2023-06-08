// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/** 
 * @title IDaoFactory
 * @notice The IDaoFactory has a struct for clonning Dao. 
 */

interface ISalesDistributor {

     struct DistributionDetails {
        address nftAddress;
        string orderId;
        uint256 totalSale;
        uint256 totalProfit;
    }


}