// SPDX-License-Identifier: MIT
pragma solidity 0.5.15;

import "../../../decentracraft-contracts/contracts/Decentracraft.sol";


contract EPDebtNFT is Decentracraft {

    struct Installment{
        uint256 amount;
        uint256 deadline;
        bool paid;
    }

    struct LoanInfo{
        uint256 startTime;
        uint installmentsCount;
        mapping (uint => Installment) installments;
        address borrower;
        address borrowedAsset;
        uint256 borrowedAmount;
        uint borrowedAssetType;
        bool loanFunded;
        address paymentAsset;
        uint paymentAssetType;
    }

    mapping (uint256 => LoanInfo) public loansInfo;

    address public crafter;

    constructor() public {
        name = "EtherPay Debt NFT";
        symbol = "EPDBT";
        contracturi = "https://nft-image-service.herokuapp.com/strain.json";
        tokenbaseuri = "https://nft-image-service.herokuapp.com/";
    }

    function burn(address account, uint256 id, uint256 amount) public ownerOnly {
        super.burn(account, id, amount);
        delete loansInfo[id];
    }

    function setCrafter(address _crafter) public ownerOnly {
        crafter = _crafter;
    }

    function setLoanInfo(uint256 _id, address _borrower, address _borrowedAsset, uint256 _borrowedAmount, uint _borrowedAssetType
                , address _paymentAsset, uint _paymentAssetType,  uint256[] memory _amounts, uint256[] memory _deadlines) public {
        require(msg.sender == crafter);

        LoanInfo memory loan = LoanInfo(0, _amounts.length, _borrower, _borrowedAsset, _borrowedAmount, _borrowedAssetType
                                    , false, _paymentAsset, _paymentAssetType);
        loansInfo[_id] = loan;
        for(uint i = 0; i < _amounts.length; i++){
            loansInfo[_id].installments[i] = Installment(_amounts[i], _deadlines[i], false);
        }
    }

    function loanFunded(uint256 _id) public {
        require(msg.sender == crafter);
        loansInfo[_id].loanFunded = true;
        loansInfo[_id].startTime  = block.timestamp;
    }

    function installmentPaid(uint256 _id, uint _installmentIndex) public {
        require(msg.sender == crafter);
        loansInfo[_id].installments[_installmentIndex].paid = true;
    }

    function getInstallment(uint256 _id, uint _installmentIndex) public view returns(uint256 amount, uint256 deadline, bool paid){
        Installment memory installment = loansInfo[_id].installments[_installmentIndex];
        return (installment.amount, installment.deadline, installment.paid);
    }

    function getStartTime(uint256 _id) public view returns(uint256){
        return loansInfo[_id].startTime;
    }

    function getInstallmentsCount(uint256 _id) public view returns(uint){
        return loansInfo[_id].installmentsCount;
    }

    function getBorrower(uint256 _id) public view returns(address){
        return loansInfo[_id].borrower;
    }

    function getBorrowedAsset(uint256 _id) public view returns(address){
        return loansInfo[_id].borrowedAsset;
    }

    function getBorrowedAmount(uint256 _id) public view returns(uint256){
        return loansInfo[_id].borrowedAmount;
    }

    function getLoanFunded(uint256 _id) public view returns(bool){
        return loansInfo[_id].loanFunded;
    }

    function getPaymentAsset(uint256 _id) public view returns(address){
        return loansInfo[_id].paymentAsset;
    }

    function getPaymentAssetType(uint256 _id) public view returns(uint){
        return loansInfo[_id].paymentAssetType;
    }

    function getBorrowedAssetType(uint256 _id) public view returns(uint){
        return loansInfo[_id].borrowedAssetType;
    }

}
