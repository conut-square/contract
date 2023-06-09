// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "hardhat/console.sol";

contract UpgradeMarketplace is ERC721URIStorageUpgradeable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    // 회사 주소
    address payable platform;

    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable creator;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event MarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address creator,
        address owner,
        uint256 price,
        bool sold
    );
    
    function initialize() initializer public {
        __ERC721_init("Denaissance Tokens", "ETH");
        
        platform = payable(msg.sender);    
    }

    // 민팅
    function OrderMint(
        bool isFirst,
        uint256 tokenId,
        string memory tokenURI,
        address seller,
        address creator,
        address serviceOwner,
        uint256 createFee,
        uint256 serviceFee,
        uint256 sellerPrice
    ) public payable returns (uint) {
        uint256 newTokenId = tokenId;

        if (isFirst) {
            // 민팅
            _mint(seller, newTokenId);
            _setTokenURI(newTokenId, tokenURI);
        }

        // 리스팅
        _transfer(seller, msg.sender, newTokenId);
        
        if (createFee > 0) {
            payable(creator).transfer(createFee);
        }
        
        payable(seller).transfer(sellerPrice);
        payable(serviceOwner).transfer(serviceFee);

        return newTokenId;
    }
    
    // 민팅
    function Mint(string memory tokenURI, uint256 price) public payable returns (uint) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }

    function createMarketItem(
        uint256 tokenId,
        uint256 price
    ) private {
        require(price > 0, "Price must be at least 1 wei");

        idToMarketItem[tokenId] =  MarketItem(
            tokenId,
            payable(msg.sender), // seller
            payable(msg.sender), // creator
            payable(address(this)), // owner
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            tokenId,
            msg.sender,
            msg.sender,
            address(this),
            price,
            false
        );
    }

    // 재판매
    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
        
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);

        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    // NFT 거래
    function Order(
        uint256 tokenId,
        uint256 createFee,
        uint256 serviceFee,
        uint256 sellerPrice
    ) public payable {
        uint price = idToMarketItem[tokenId].price;
        address seller = idToMarketItem[tokenId].seller;
        address creator = idToMarketItem[tokenId].creator;

        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(msg.sender);
        _itemsSold.increment();

        _transfer(address(this), msg.sender, tokenId);
        

        payable(creator).transfer(createFee);
        payable(seller).transfer(sellerPrice);
        payable(platform).transfer(serviceFee);
    }

    // 전체 마켓 아이템 가져오기
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _tokenIds.current();
        // uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](itemCount);
        
        for (uint i = 0; i < itemCount; i++) {
            // if (idToMarketItem[i + 1].owner == address(this)) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            // }
        }
        return items;
    }

    // 보유중 NFT 가져오기
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].creator == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function foo() public view returns(address) {
        return msg.sender;
    }

    // 창작한 NFT 가져오기
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
            itemCount += 1;
        }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
            uint currentId = i + 1;
            MarketItem storage currentItem = idToMarketItem[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
    }
        return items;
    }
}