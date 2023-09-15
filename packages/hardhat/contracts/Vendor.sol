pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);

	YourToken public yourToken;
	uint256 public constant tokensPerEth = 100;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() public payable {
		require(msg.sender != address(0), "Zero address");
		require(msg.value > 0, "Amount must be greater than 0");
		uint256 amountOfTokens = msg.value * tokensPerEth;
		yourToken.transfer(msg.sender, amountOfTokens);
		emit BuyTokens(msg.sender, msg.value, amountOfTokens);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() public onlyOwner {
		require(address(this).balance > 0, "No ETH to withdraw");
		(bool success, ) = payable(msg.sender).call{
			value: address(this).balance
		}("");
		require(success, "Withdraw failed");
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 _amount) public {
		require(
			yourToken.balanceOf(address(this)) >= _amount,
			"Not enough tokens"
		);
		require(
			yourToken.allowance(msg.sender, address(this)) >= _amount,
			"Not enough allowance"
		);
		yourToken.transferFrom(msg.sender, address(this), _amount);
		uint256 amountOfEth = _amount / tokensPerEth;
		(bool success, ) = payable(msg.sender).call{ value: amountOfEth }("");
		require(success, "Sell failed");
		emit SellTokens(msg.sender, _amount, amountOfEth);
	}
}
