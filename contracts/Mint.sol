pragma solidity ^0.8.15;

import "@klaytn/contracts/KIP/token/KIP17/KIP17.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Mintable.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Burnable.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Pausable.sol";
import "@klaytn/contracts/KIP/token/KIP17/IKIP17Receiver.sol";
import "@klaytn/contracts/KIP/token/KIP17/IKIP17.sol";
import "@klaytn/contracts/access/Ownable.sol";


contract Mint is KIP17("TEST", "TEST"), Ownable {
    using Address for address payable;
    using Strings for uint256;

    string private _baseTokenURI;
    bool private _saleStatus = false;
    uint256 private _salePrice = 0.005 ether;
    uint256 private _teamSupply = 88;
    uint256 private _reservedSupply;

    uint256 public MAX_SUPPLY = 8888;
    uint256 public FREE_PER_WALLET = 2;
    uint256 public MAX_MINTS_PER_TX = 5;
    uint256 public MAX_PER_WALLET = 5;

        modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    function setMaxMintPerTx(uint256 maxMint) external onlyOwner {
        MAX_MINTS_PER_TX = maxMint;
    }

    function setSalePrice(uint256 price) external onlyOwner {
        _salePrice = price;
    }

    function toggleSaleStatus() external onlyOwner {
        _saleStatus = !_saleStatus;
    }

    function mint(uint256 tokenId) external payable callerIsUser {
        _safeMint(msg.sender, tokenId);
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _startTokenId() internal pure returns (uint256) {
        return 1;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

        return string(abi.encodePacked(_baseTokenURI, tokenId.toString(), ".json"));
    }


    function isSaleActive() public view returns (bool) {
        return _saleStatus;
    }

    function getSalePrice() public view returns (uint256) {
        return _salePrice;
    }


}
