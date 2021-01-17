// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "./SafeMath.sol";

contract Initialise {
    using SafeMath for uint;

    mapping(address => userData) users;             // user address assigned to personal info sheet
    
    struct userData {
        uint256 _initialInstallmentAmount;           // the amount the user is initialising with
        uint256 _remainingInstallmentCount;          // a count of the remaining instalments to pay
        uint256 _debtAmount;                         // the amount of funds to repay in total
        uint256 _nextInstallmentDueDate;             // the block number the next instalment is due by, otherwise it is terminated
        bool _contractTermination;                   // if user doesn't pay before `_nextInstallmentDueDate`, contract is terminated 
    }

    function viewConversion (uint256 ethAmount, address tokenAddress) 
        external 
        view 
        returns (
            uint256 ethAmountInputted, 
            address tokenAdressInputted, 
            uint256 amountOfTokensConvertible
        ) {
            // fetch token address's price
            // div ethAmount by token price
            // return above.
    }

    function viewInstallmentDetails () 
        external 
        view 
        returns (
            uint256 initialInstallmentAmount,
            uint256 remainingInstallmentCount,
            uint256 debtAmount,
            uint256 nextInstallmentDueDate
        ) {
            return (
                users[msg.sender]._initialInstallmentAmount,
                users[msg.sender]._remainingInstallmentCount,
                users[msg.sender]._debtAmount,
                users[msg.sender]._nextInstallmentDueDate
            );
    }
}