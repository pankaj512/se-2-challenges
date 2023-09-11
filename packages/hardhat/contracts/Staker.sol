// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	ExampleExternalContract public exampleExternalContract;

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
		// deadline = block.timestamp + 30 seconds; // 30 seconds
		deadline = block.timestamp + 365 days; // 30 seconds
	}

	mapping(address => uint256) public balances;
	uint256 immutable deadline;
	uint256 public threshold = 10 ether;
	bool public withdrawAllowed = false;

	modifier notCompleted() {
		require(
			exampleExternalContract.completed() == false,
			"staking completed"
		);
		_;
	}

	modifier beforedeadline() {
		require(block.timestamp < deadline, "Not allowed after deadline");
		_;
	}

	modifier afterdeadline() {
		require(block.timestamp >= deadline, "Not allowed before deadline");
		_;
	}

	// Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
	// (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
	event Stake(address staker, uint256 amount);

	function stake() public payable notCompleted beforedeadline {
		require(msg.sender != address(0), "zero address");
		require(msg.value > 0, "must stake positive value");
		require(!withdrawAllowed, "deposit not allowed after execute");
		balances[msg.sender] += msg.value;
		emit Stake(msg.sender, msg.value);
	}

	// After some `deadline` allow anyone to call an `execute()` function
	// If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
	function execute() public afterdeadline {
		require(msg.sender != address(0), "zero address");
		require(withdrawAllowed == false, "already executed");
		if (address(this).balance >= threshold) {
			exampleExternalContract.complete{ value: address(this).balance }();
		} else {
			withdrawAllowed = true;
		}
	}

	// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
	function withdraw() public afterdeadline {
		require(withdrawAllowed, "withdraw not allowed yet");
		require(
			address(this).balance < threshold,
			"can't withdraw after thresold is met"
		);
		require(balances[msg.sender] > 0, "you have not staked any fund");
		uint amount = balances[msg.sender];
		balances[msg.sender] = 0;
		(bool success, ) = msg.sender.call{ value: amount }("");
		require(success, "withdraw failed");
	}

	// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
	function timeLeft() public view returns (uint256) {
		return (deadline > block.timestamp) ? deadline - block.timestamp : 0;
	}

	// Add the `receive()` special function that receives eth and calls stake()
	receive() external payable {
		stake();
	}

	fallback() external payable {}
}
