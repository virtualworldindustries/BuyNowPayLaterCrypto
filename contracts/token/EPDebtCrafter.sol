// SPDX-License-Identifier: MIT
pragma solidity 0.5.15;

import "../../../decentracraft-contracts/contracts/DecentracraftWorld.sol";
import "../../../decentracraft-contracts/contracts/DecentracraftCrafter.sol";
import "./EPDebtNFT.sol";
// import "../lib/SafeERC20.sol";
import "../../../decentracraft-contracts/contracts/SafeERC20.sol";

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}



contract EPDebtCrafter is DecentracraftCrafter {

    EPDebtNFT public epDebtNFT;

    constructor(address payable _epDebtNFT) public {
        epDebtNFT = EPDebtNFT(_epDebtNFT);
    }

    function __callback(bytes32 _queryId, uint256 _rng) public ownerOnly{
        
    } 


}
