// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract ZizzoToken {
    // STATE VARIABLES
    // Token name state variable
    string public name = "Zizzo Token";

    // The token symbol shown on exchanges
    string public symbol = "ZTK";

    // Decimal places like ETH
    uint8 public decimals = 18;

    // The total number of tokens that will ever exist
    uint256 public totalSupply;

    // CONSTRUCTOR
    constructor(uint256 initialSupply) {
        // Multiply by 10^18 to account for 18 decimal places
        totalSupply = initialSupply * 10 ** getDecimals();

        // Give all tokens to the account deploying the contract
        balances[msg.sender] = totalSupply;

        // Emit a Transfer from the zero address to signal tokens were minted
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // MAPPINGS
    // Token balances of accounts
    mapping(address => uint256) private balances;

    // Maps account Owners to Spenders & determines spending level
    mapping(address => mapping(address => uint256)) private allowances;

    // EVENTS
    // Logs when tokens move between two addresses
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Logs when an owner approves a spender
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // FUNCTION LOGICS

    // Function to return the Token name
    function getName() public view returns (string memory) {
        return name;
    }

    // Function to return the Token symbol
    function getSymbol() public view returns (string memory) {
        return symbol;
    }

    // Function to return the decimal of token
    function getDecimals() public view returns (uint8) {
        return decimals;
    }

    // Function returns the token balance of any address
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // Function to send tokens from your owner's wallet to someone else
    function transfer(address to, uint256 amount) public returns (bool) {
        // The sender must have enough tokens
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // The destination address must not be the zero address
        require(to != address(0), "Cannot transfer to zero address");

        // Deduct value from the sender
        balances[msg.sender] = balances[msg.sender] - amount;

        // Add value to the recipient wallet
        balances[to] = balances[to] + amount;

        // Log the transfer event on-chain
        emit Transfer(msg.sender, to, amount);

        // Return success after function execution
        return true;
    }

    // Function allows 'spender' to use up to stipulated 'amount' of owner's tokens
    function approve(address spender, uint256 amount) public returns (bool) {
        // The spender must be a real address
        require(spender != address(0), "Cannot approve zero address");

        // Record the allowance (transaction) in the nested mapping
        allowances[msg.sender][spender] = amount;

        // Log the approval so the spender (and block explorers) know about it
        emit Approval(msg.sender, spender, amount);

        // Return success after function execution
        return true;
    }

    // Function checsk how much tokens 'spender' is still allowed to use from 'owner'
    function checkAllowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return allowances[owner][spender];
    }

    // Function to allow a pre-approved spender moves tokens from 'from' to 'to'
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        // The owner must have enough tokens
        require(balances[from] >= amount, "Not enough tokens");

        // The caller (spender) must have been approved for at least this amount
        require(allowances[from][msg.sender] >= amount, "Allowance too low");

        // The destination must be valid
        require(to != address(0), "Cannot transfer to zero address");

        // Reduce the allowance so it can't be reused
        allowances[from][msg.sender] = allowances[from][msg.sender] - amount;

        // Move the tokens
        balances[from] = balances[from] - amount;
        balances[to] = balances[to] + amount;

        // Log the transfer
        emit Transfer(from, to, amount);

        // Return success after function execution
        return true;
    }
}
