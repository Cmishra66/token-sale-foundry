// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSale is Ownable {
    ERC20 public token;  // ERC-20 token being sold

    uint256 public presaleCap;
    uint256 public publicSaleCap;

    uint256 public presaleMinContribution;
    uint256 public presaleMaxContribution;

    uint256 public publicSaleMinContribution;
    uint256 public publicSaleMaxContribution;

    uint256 public presaleEndTime;
    uint256 public publicSaleStartTime;
    uint256 public publicSaleEndTime;

    mapping(address => uint256) public presaleContributions;
    mapping(address => uint256) public publicSaleContributions;

    bool public presaleClosed = false;
    bool public publicSaleClosed = false;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 totalContribution, bool isPresale);
    event TokensDistributed(address indexed recipient, uint256 amount);
    event RefundClaimed(address indexed contributor, uint256 amount);

    constructor(
        ERC20 _token,
        uint256 _presaleCap,
        uint256 _publicSaleCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution,
        uint256 _presaleEndTime,
        uint256 _publicSaleStartTime,
        uint256 _publicSaleEndTime
    ) {
        token = _token;
        presaleCap = _presaleCap;
        publicSaleCap = _publicSaleCap;
        presaleMinContribution = _presaleMinContribution;
        presaleMaxContribution = _presaleMaxContribution;
        publicSaleMinContribution = _publicSaleMinContribution;
        publicSaleMaxContribution = _publicSaleMaxContribution;
        presaleEndTime = _presaleEndTime;
        publicSaleStartTime = _publicSaleStartTime;
        publicSaleEndTime = _publicSaleEndTime;
    }

    modifier onlyDuringPresale() {
        require(block.timestamp < presaleEndTime, "Presale has ended");
        require(!presaleClosed, "Presale is closed");
        _;
    }

    modifier onlyDuringPublicSale() {
        require(block.timestamp >= publicSaleStartTime && block.timestamp < publicSaleEndTime, "Public sale is not active");
        require(!publicSaleClosed, "Public sale is closed");
        _;
    }

    modifier onlyOwnerOrAdmin() {
        require(owner() == msg.sender, "Caller is not the owner");
        _;
    }

    function contributeToPresale() external payable onlyDuringPresale {
        require(msg.value >= presaleMinContribution && msg.value <= presaleMaxContribution, "Invalid contribution amount");

        uint256 totalContribution = presaleContributions[msg.sender] + msg.value;
        require(totalContribution <= presaleMaxContribution, "Exceeded maximum contribution limit");

        presaleContributions[msg.sender] = totalContribution;

        require(address(this).balance <= presaleCap, "Presale cap reached");

        uint256 tokenAmount = calculateTokenAmount(msg.value);
        token.transfer(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, tokenAmount, totalContribution, true);
    }

    function contributeToPublicSale() external payable onlyDuringPublicSale {
        require(msg.value >= publicSaleMinContribution && msg.value <= publicSaleMaxContribution, "Invalid contribution amount");

        uint256 totalContribution = publicSaleContributions[msg.sender] + msg.value;
        require(totalContribution <= publicSaleMaxContribution, "Exceeded maximum contribution limit");

        publicSaleContributions[msg.sender] = totalContribution;

        require(address(this).balance <= publicSaleCap, "Public sale cap reached");

        uint256 tokenAmount = calculateTokenAmount(msg.value);
        token.transfer(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, tokenAmount, totalContribution, false);
    }

    function distributeTokens(address _recipient, uint256 _amount) external onlyOwnerOrAdmin {
        require(_amount > 0, "Amount should be greater than 0");
        token.transfer(_recipient, _amount);
        emit TokensDistributed(_recipient, _amount);
    }

    function claimRefund() external {
        require((block.timestamp >= presaleEndTime && !presaleClosed) || (block.timestamp >= publicSaleEndTime && !publicSaleClosed), "Refund not allowed yet");

        uint256 refundAmount = 0;

        if (presaleClosed && presaleContributions[msg.sender] > 0) {
            refundAmount += presaleContributions[msg.sender];
            presaleContributions[msg.sender] = 0;
        }

        if (publicSaleClosed && publicSaleContributions[msg.sender] > 0) {
            refundAmount += publicSaleContributions[msg.sender];
            publicSaleContributions[msg.sender] = 0;
        }

        require(refundAmount > 0, "No refund available");

        payable(msg.sender).transfer(refundAmount);
        emit RefundClaimed(msg.sender, refundAmount);
    }

    function calculateTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        // Implement your token rate calculation logic here
        // This is just a placeholder, replace it with your actual calculation
        uint256 rate = 100;  // 1 ETH = 100 tokens
        return _weiAmount * rate;
    }

    // Owner can close the presale and start the public sale
    function closePresaleAndStartPublicSale() external onlyOwnerOrAdmin {
        require(block.timestamp >= presaleEndTime, "Presale is still active");

        presaleClosed = true;
        publicSaleStartTime = block.timestamp;
    }

    // Owner can close the public sale
    function closePublicSale() external onlyOwnerOrAdmin {
        require(block.timestamp >= publicSaleEndTime, "Public sale is still active");

        publicSaleClosed = true;
    }

    // Owner can extend the presale and public sale end times
    function extendSalePeriod(uint256 _presaleEndTime, uint256 _publicSaleEndTime) external onlyOwnerOrAdmin {
        presaleEndTime = _presaleEndTime;
        publicSaleEndTime = _publicSaleEndTime;
    }

    // Withdraw excess funds from the contract (if any)
    function withdrawExcessFunds() external onlyOwnerOrAdmin {
        require(address(this).balance > presaleCap + publicSaleCap, "No excess funds");
        payable(owner()).transfer(address(this).balance - presaleCap - publicSaleCap);
    }
}
