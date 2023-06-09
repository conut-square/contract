/*
    SPDX-License-Identifier: MIT
    Create by. Jacob 2022. 11. 17
*/
pragma solidity ^0.8.7;

import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17URIStorage.sol";

contract KlaytnKIP17 is KIP17URIStorage {
    address owner;

    mapping (uint256 => string) private _uris;
    mapping (uint256 => address) private creatorList;
    mapping (string => address) private marketOwnerList;

    /*
        발행정보
    */
    event assetInformation (
        uint256 indexed tokenId,
        string tokenUri,
        address ownerAdress 
    );

    /*
        상장정보
    */
    event marketInformation (
        string indexed marektId,
        uint256 tokenId,
        string tokenUri,
        address ownerAdress 
    );

    /*
        구매정보
    */
    event orderInformation (
        string indexed marektId,
        uint256 tokenId,
        string tokenUri,
        address sellerAdress,
        address buyerAdress 
    );

    constructor() KIP17("CONUT_NFT", "CONUT") {
        owner = msg.sender;
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    /*
        Set ApprovalForAll
    */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(msg.sender == owner, 'Only Owner!');

        _setApprovalForAll(owner, operator, approved);
    }

    /*
        Delete ApprovalForAll
    */
    function deleteApprovalForAll(address operator) public virtual {
        require(msg.sender == owner || isApprovedForAll(owner, operator), 'Only Owner!');

        _setApprovalForAll(owner, operator, false);
    }

    function mintSingle(uint256 _tokenId, string memory _tokenURI, address _creator) public  {
        _mint(_creator, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);

        /* Creator Adress를 TokenId에 맵핑 */
        creatorList[_tokenId] = _creator;

        /* 해당 거래를 블록에 기록해 준다. */
        emit assetInformation (
            _tokenId,
            _tokenURI,
            _creator
        );
    }

    function mintMulty(uint256 _tokenId, string memory _tokenURI, uint256 _quantity) public {
        require(_quantity > 0, "Check Quantity!");

        for (uint256 i = 0; i < _quantity; i++) {
            _mint(msg.sender, _tokenId);
            _setTokenURI(_tokenId, _tokenURI);
        }
    }

    /* 
        상장할때 마켓에 Owner를 저장해준다.
    */ 
    function setListing(
        string memory _marketId,
        uint256 _tokenId,
        string memory _tokenUri,
        address _seller
    ) public returns(string memory) {
        require(owner == msg.sender, 'Only Owner!');
        require(bytes(_marketId).length > 0, 'Check Market Id!');
        require(_tokenId > 0, 'Check Token Id!');
        require(bytes(_tokenUri).length > 0, 'Check Token Uri!');
        
        /* Seller Adress를 MarketId에 맵핑 */
        marketOwnerList[_marketId] = _seller;
        
        /* Seller setApprove */
        setApprovalForAll(_seller, true);

        /* 해당 거래를 블록에 기록해 준다. */
        emit marketInformation (
            _marketId,
            _tokenId,
            _tokenUri,
            _seller
        );

        return _marketId;
    }

    function setOrder(
        string memory _marketId,
        uint256 _tokenId,
        uint256 _createFee,
        uint256 _serviceFee,
        uint256 _sellerPrice,
        string memory _tokenUri,
        bool _isBalanceEmpty
    ) public payable {
        require(msg.sender == owner || isApprovedForAll(owner, marketOwnerList[_marketId]), 'Only Owner or Approved!');
        require(bytes(_marketId).length > 0, 'Check Market Id!');
        // require(balanceOf(marketOwnerList[_marketId], _tokenId) >= _quantity, 'Check Quantity!');
        require(_tokenId > 0, 'Check Token Id!');
        require(bytes(_tokenUri).length > 0, 'Check Token Uri!');
        require(_createFee + _serviceFee + _sellerPrice  == msg.value, 'Check Price!');

        /*
            구매자에게 수량 만큼 asset을 전송
        */
        _safeTransfer(marketOwnerList[_marketId], msg.sender, _tokenId, "0x00");

        /*
            Create Fee 분배
            0% 일때는 그냥 통과한다.
        */
        if (_createFee > 0) {
            payable(creatorList[_tokenId]).transfer(_createFee);
        }

        /*
            Service Fee -> 2.5% 분배
            Seller에게는 판매가
            (크리에이터 수수료 - 서비스 수수료) 계산 후 전송
        */
        payable(marketOwnerList[_marketId]).transfer(_sellerPrice);
        payable(owner).transfer(_serviceFee);

        /*
            가지고 있는 수량이 없으면 권한 제거
        */
        if (_isBalanceEmpty) {
            deleteApprovalForAll(marketOwnerList[_marketId]);
        }
        
        
        /* 해당 거래를 블록에 기록해 준다. */
        emit orderInformation (
            _marketId,
            _tokenId,
            _tokenUri,
            marketOwnerList[_marketId],
            msg.sender
        );
    }

    function setKrwOrder(
        string memory _marketId,
        uint256 _tokenId,
        string memory _tokenUri,
        bool _isBalanceEmpty,
        address buyer
    ) public {
        require(msg.sender == owner, 'Only Owner!');
        require(bytes(_marketId).length > 0, 'Check Market Id!');
        // require(balanceOf(marketOwnerList[_marketId], _tokenId) >= _quantity, 'Check Quantity!');
        require(_tokenId > 0, 'Check Token Id!');
        require(bytes(_tokenUri).length > 0, 'Check Token Uri!');

        /*
            구매자에게 수량 만큼 asset을 전송
        */
        _safeTransfer(marketOwnerList[_marketId], buyer, _tokenId, "0x00");

        /*
            가지고 있는 수량이 없으면 권한 제거
        */
        if (_isBalanceEmpty) {
            deleteApprovalForAll(marketOwnerList[_marketId]);
        }

        /* 해당 거래를 블록에 기록해 준다. */
        emit orderInformation (
            _marketId,
            _tokenId,
            _tokenUri,
            marketOwnerList[_marketId],
            buyer
        );
    }
}