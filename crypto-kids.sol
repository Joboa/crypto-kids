//SPDX-License-Identifier: MIT

// Declare the versions of the solidity compiler
pragma solidity >=0.7.0 <0.9.0;

contract CrpytoKids {
    // Owner Dad
    address owner;

    event LogKidFundingReceived(
        address addr,
        uint256 amount,
        uint256 contractBalance
    );

    constructor() {
        owner = msg.sender;
    }

    // Define kid
    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint256 releaseTime;
        uint256 amount;
        bool canWithdraw;
    }

    Kid[] public kids;

    // Only owner can add kid
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can add kids");
        _;
    }

    // Add kids to the contract
    function addKidAddress(
        address payable _walletAddress,
        string memory _firstName,
        string memory _lastName,
        uint256 _releaseTime,
        uint256 _amount,
        bool _canWithdraw
    ) public onlyOwner {
        kids.push(
            Kid(
                _walletAddress,
                _firstName,
                _lastName,
                _releaseTime,
                _amount,
                _canWithdraw
            )
        );
    }

    // Check balance
    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    // Get index of kid
    function getIndex(address _walletAddress) private view returns (uint256) {
        for (uint256 i = 0; i < kids.length; i++) {
            if (kids[i].walletAddress == _walletAddress) {
                return i;
            }
        }
        return kids.length;
    }

    // Add to kid balance
    function addToKidsBalance(address _walletAddress) private onlyOwner {
        uint256 i = getIndex(_walletAddress);
        kids[i].amount += msg.value;
        emit LogKidFundingReceived(_walletAddress, msg.value, balanceOf());
    }

    // Deposit funds to a kid's account
    function deposit(address _walletAddress) public payable {
        addToKidsBalance(_walletAddress);
    }

    // Check if kids is able to withdraw
    function availableToWithdraw(address _walletAddress) public returns (bool) {
        uint256 i = getIndex(_walletAddress);
        require(block.timestamp > kids[i].releaseTime, "You cannot withdraw");
        if (block.timestamp > kids[i].releaseTime) {
            kids[i].canWithdraw = true;
            return true;
        }
        return false;
    }

    // Withdraw money
    function withDraw(address payable _walletAddress) public payable {
        uint256 i = getIndex(_walletAddress);
        require(
            msg.sender == kids[i].walletAddress,
            "You must be the kid to withdraw"
        );
        require(kids[i].canWithdraw == true, "You can't withdraw at this time");
        kids[i].walletAddress.transfer(kids[i].amount);
    }
}
