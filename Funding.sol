// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import"./PriceConverter.sol";
error NotOwner();

contract Fund{
    using PriceConverter for uint256;
    // to get funds
    // to withdraw
    // set a min value for funds

    uint256 public constant MINIMUM_USD=50* 1e18;
    address[] public funders;
    mapping(address=> uint256) public FundersToAmount;
    address public immutable i_owner;
    constructor(){
       i_owner= msg.sender;
    }
    function getFunds()public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough!!");
        funders.push(msg.sender);
        FundersToAmount[msg.sender]=msg.value;

    }
    function withdraw() public {
       
        for (uint256 fundersIndex=0; fundersIndex< funders.length; fundersIndex++){
            address funder= funders[fundersIndex];
            FundersToAmount[funder]=0;
        }
        //reset the array
        funders= new address[](0);
        // withdraw funds
        payable(msg.sender).transfer(address(this).balance); // transfer reverts if 2300 gas exceeds
        // send
       /* bool sendsuccess= payable(msg.sender).send(address(this).balance);// returns bool if not then not revert
        // to revert we need require
        require(sendsuccess, "send Failed");*/
        // call another field is bytes dataReturned forward all gas
        (bool callsuccesss, )= payable(msg.sender).call{value: address(this).balance}("");
        require(callsuccesss, "call failed");

    }
    modifier onlyOwnder{
     //require(msg.sender == i_owner, "sender is not owner");
    if (msg.sender != i_owner) revert NotOwner();
     _;
    }
    receive() external payable{
        getFunds();
    }
    fallback() external payable {
        getFunds();
    }    }
