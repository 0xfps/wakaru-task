// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./IBEP20.sol";

contract BUSDWallet {
    IBEP20 public busdToken;

    event Transfer(address indexed to, address indexed from, uint256 amount);
    constructor(address _busdAddress) {
        busdToken = IBEP20(_busdAddress);   
    }

    function sendToken(address to, uint256 amount) external {
        require(to != address(0), "Invalid Address");
        require(amount <= balanceToken(msg.sender), "Insufficent Fund");
        
        busdToken.transfer(to, amount);
        emit Transfer(to, msg.sender, amount);
    }

    function receiveToken(uint256 amount) external {
        busdToken.transferFrom(msg.sender, address(this), amount);
        
        emit Transfer(address(this), msg.sender, amount);
    }
    
    function balanceToken(address client) public view returns (uint256) {
        require(client != address(0), "Invalid Address");
        return busdToken.balanceOf(client);
    }

    function getBUSDBalanceContract() external view returns (uint256) {
        return busdToken.balanceOf(address(this));
    }
    
}