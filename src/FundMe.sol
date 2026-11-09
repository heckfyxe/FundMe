// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {PriceConverter} from "./PriceConverter.sol";
using PriceConverter for uint256;

error NotOwner();
error SmallAmount();
error TransferFailed();

contract FundMe {
    uint256 constant public MINIMAL_USD = 5e18;

    uint256 private round;
    mapping(uint256 => mapping(address => uint256)) public addressToAmountFunded;

    address immutable public i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == i_owner, NotOwner());
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(msg.value.getConversionRate() > MINIMAL_USD, SmallAmount());
        addressToAmountFunded[round][msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        round++;
        (bool ok,) = i_owner.call{value: address(this).balance}("");
        require(ok, TransferFailed());
    }
}
