// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.3;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
}

contract SaveERC20 {
    mapping(address => uint256) public etherBalances;

    mapping(address => mapping(address => uint256)) public tokenBalances;

    event EtherDeposited(address indexed sender, uint256 amount);
    event EtherWithdrawn(address indexed receiver, uint256 amount);
    event TokenDeposited(
        address indexed sender,
        address indexed token,
        uint256 amount
    );
    event TokenWithdrawn(
        address indexed receiver,
        address indexed token,
        uint256 amount
    );

    function depositEther() external payable {
        require(msg.value > 0, "Cannot deposit zero Ether");

        etherBalances[msg.sender] += msg.value;

        emit EtherDeposited(msg.sender, msg.value);
    }

    function withdrawEther(uint256 amount) external {
        require(msg.sender != address(0), "Zero address detected");
        require(
            etherBalances[msg.sender] >= amount,
            "Insufficient Ether savings"
        );

        // Always deduct before making external calls to prevent reentrancy attacks
        etherBalances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Ether transfer failed");

        emit EtherWithdrawn(msg.sender, amount);
    }

    function depositToken(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Cannot deposit zero tokens");
        require(tokenAddress != address(0), "Invalid token address");

        IERC20 token = IERC20(tokenAddress);

        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        tokenBalances[msg.sender][tokenAddress] += amount;

        emit TokenDeposited(msg.sender, tokenAddress, amount);
    }

    function withdrawToken(address tokenAddress, uint256 amount) external {
        require(msg.sender != address(0), "Zero address detected");
        require(tokenAddress != address(0), "Invalid token address");
        require(
            tokenBalances[msg.sender][tokenAddress] >= amount,
            "Insufficient token savings"
        );

        tokenBalances[msg.sender][tokenAddress] -= amount;

        IERC20 token = IERC20(tokenAddress);

        bool success = token.transfer(msg.sender, amount);
        require(success, "Token withdrawal failed");

        emit TokenWithdrawn(msg.sender, tokenAddress, amount);
    }

    function getMyEtherSavings() external view returns (uint256) {
        return etherBalances[msg.sender];
    }

    function getMyTokenSavings(
        address tokenAddress
    ) external view returns (uint256) {
        return tokenBalances[msg.sender][tokenAddress];
    }

    function getContractEtherBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}

    fallback() external {}
}
