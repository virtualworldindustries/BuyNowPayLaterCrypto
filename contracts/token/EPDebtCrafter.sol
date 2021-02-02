// SPDX-License-Identifier: MIT
pragma solidity 0.5.15;

import "../../../decentracraft-contracts/contracts/DecentracraftWorld.sol";
import "../../../decentracraft-contracts/contracts/DecentracraftCrafter.sol";
import "../../../decentracraft-contracts/contracts/IERC1155TokenReceiver.sol";
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



contract EPDebtCrafter is DecentracraftCrafter, ERC1155TokenReceiver {
    using SafeERC20 for IERC20;

    EPDebtNFT public epDebtNFT;

    constructor(address payable _epDebtNFT) public {
        epDebtNFT = EPDebtNFT(_epDebtNFT);
    }

    function __callback(bytes32 _queryId, uint256 _rng) public ownerOnly{        
    } 

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4){
        return 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4){
        return 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
    }

    function transfer(uint _tokenType, address _token, address _from, address _to, uint256 _value) private {
        if(_tokenType == 0){            
            IERC20(_token).safeTransferFrom(_from, _to, _value);
        }
    }

    function createDebt(address _borrowedAsset, uint256 _borrowedAmount, uint _borrowedAssetType, 
                            address _paymentAsset, uint _paymentAssetType, uint256[] memory _amounts, uint256[] memory _deadlines) public {
        require(_amounts.length == _deadlines.length, "Amounts and Deadlines dont match."); 

        DecentracraftWorld dccworld = DecentracraftWorld(address(uint160(owner)));

        address[] memory playersaddresses= new address[](1);
        playersaddresses[0] = address(this);     

        uint256 nfttype = dccworld.create("", true);
        uint256 nftid = dccworld.craft(nfttype, playersaddresses, "", "");
        epDebtNFT.setLoanInfo(nftid, msg.sender, _borrowedAsset, _borrowedAmount, _borrowedAssetType, 
                            _paymentAsset, _paymentAssetType, _amounts, _deadlines);
    }

    function fundLoan(uint256 _id) public payable {
        require(epDebtNFT.ownerOf(_id) == address(this), "Loan already funded."); 

        address borrowedasset = epDebtNFT.getBorrowedAsset(_id);
        uint256 borrowedamount = epDebtNFT.getBorrowedAmount(_id);
        uint borrowedassettype = epDebtNFT.getBorrowedAssetType(_id);
        
        //IERC20(borrowedasset).safeTransferFrom(msg.sender, address(this), borrowedamount);
        transfer(borrowedassettype, borrowedasset, msg.sender, address(this), borrowedamount);

        epDebtNFT.loanFunded(_id);

        epDebtNFT.safeTransferFrom(address(this), msg.sender, _id, 1, "");
    }

    function payNextInstallment(uint256 _id) public payable {
        require(epDebtNFT.ownerOf(_id) != address(this), "Loan not funded yet."); 

        address paymentasset = epDebtNFT.getPaymentAsset(_id);
        uint paymentassettype = epDebtNFT.getPaymentAssetType(_id);
        uint installmentscount = epDebtNFT.getInstallmentsCount(_id);
        
        for(uint i = 0; i < installmentscount; i++){
            (uint256 amount, uint256 deadline, bool paid) = epDebtNFT.getInstallment(_id, i);
            if(!paid){
                //IERC20(paymentasset).safeTransferFrom(msg.sender, epDebtNFT.ownerOf(_id), amount);
                transfer(paymentassettype, paymentasset, msg.sender, epDebtNFT.ownerOf(_id), amount);
                epDebtNFT.installmentPaid(_id, i);

                //If last installment, fulfill loan
                if(i+1 == installmentscount){
                    address borrowedasset = epDebtNFT.getBorrowedAsset(_id);
                    uint256 borrowedamount = epDebtNFT.getBorrowedAmount(_id);
                    uint borrowedassettype = epDebtNFT.getBorrowedAssetType(_id);
                    address borrower = epDebtNFT.getBorrower(_id);

                    //IERC20(borrowedasset).safeTransferFrom(address(this), borrower, borrowedamount);
                    transfer(borrowedassettype, borrowedasset, address(this), borrower, borrowedamount);

                    epDebtNFT.burn(msg.sender, _id, 1);
                }
                break;
            }
        }
    }

    function terminateLoan(uint256 _id) public payable {
        require(epDebtNFT.ownerOf(_id) == msg.sender, "Only loan owner can temrinate loan."); 

        uint installmentscount = epDebtNFT.getInstallmentsCount(_id);
        uint starttime = epDebtNFT.getStartTime(_id);        
        
        for(uint i = 0; i < installmentscount; i++){
            (uint256 amount, uint256 deadline, bool paid) = epDebtNFT.getInstallment(_id, i);
            if(!paid){
                bool deadline_passed = (starttime + deadline) > block.timestamp;
                if(deadline_passed){
                    address borrowedasset = epDebtNFT.getBorrowedAsset(_id);
                    uint256 borrowedamount = epDebtNFT.getBorrowedAmount(_id);
                    uint borrowedassettype = epDebtNFT.getBorrowedAssetType(_id);
                    //IERC20(borrowedasset).safeTransferFrom(address(this), msg.sender, borrowedamount);
                    transfer(borrowedassettype, borrowedasset,address(this),  msg.sender, borrowedamount);
                    epDebtNFT.burn(msg.sender, _id, 1);
                }
                break;
            }
        }
    }

}
