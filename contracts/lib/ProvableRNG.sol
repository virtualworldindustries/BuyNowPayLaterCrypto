pragma solidity ^0.5.11;

import "../../../decentracraft-contracts/contracts/Utils/IRNGReceiver.sol";
import "../../../decentracraft-contracts/contracts/Utils/IRandomGenerator.sol";
import "../../../decentracraft-contracts/contracts/Utils/provableAPI.sol";
import "../../../decentracraft-contracts/contracts/Utils/Ownable.sol";

/**
    @dev RNG
*/
contract ProvableRNG is Ownable, IRandomGenerator, usingProvable {

    // uint256 constant MAX_INT_FROM_BYTE = 99999;//256;
    uint256 constant MAX_NUMBER = 10000;
    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 7;

    uint256 GAS_FOR_CALLBACK = 1500000;   

    function setGasForCall(uint256 _gas) external ownerOnly {
        GAS_FOR_CALLBACK = _gas;
    }

    event LogNewProvableQuery(string description);
    event generatedRandomNumber(uint256 randomNumber);

    mapping (bytes32 => IRNGReceiver) callingMap;

    function () external payable {
    }

    constructor () public payable  { 
        provable_setProof(proofType_Ledger);
    }

    function generateRandom() external payable ownerOnly returns (bytes32){

        uint256 QUERY_EXECUTION_DELAY = 0;         
        bytes32 queryId = provable_newRandomDSQuery(QUERY_EXECUTION_DELAY, NUM_RANDOM_BYTES_REQUESTED, GAS_FOR_CALLBACK);
        callingMap[queryId] = IRNGReceiver(msg.sender);
        emit LogNewProvableQuery("Provable query was sent, standing by for the random number...");
        return queryId;
    }

    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
        require(msg.sender == provable_cbAddress());

        if (provable_randomDS_proofVerify__returnCode(_queryId, _result, _proof) == 0) {
            /**
             *
             * @notice  The proof verifiction has passed!
             *
             *          Let's convert the random bytes received from the query
             *          to a `uint256`.
             *
             *          To do so, We define the variable `ceiling`, where
             *          `ceiling - 1` is the highest `uint256` we want to get.
             *          The variable `ceiling` should never be greater than:
             *          `(MAX_INT_FROM_BYTE ^ NUM_RANDOM_BYTES_REQUESTED) - 1`.
             *
             *          By hashing the random bytes and casting them to a
             *          `uint256` we can then modulo that number by our ceiling
             *          in order to get a random number within the desired
             *          range of [0, ceiling - 1].
             *
             */
            // uint256 ceiling = (MAX_INT_FROM_BYTE ** NUM_RANDOM_BYTES_REQUESTED) - 1;
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % MAX_NUMBER;
            emit generatedRandomNumber(randomNumber);

            callingMap[_queryId].__callback(_queryId, randomNumber);
            delete callingMap[_queryId];
        }
    }
}
