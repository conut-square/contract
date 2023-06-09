/*
    SPDX-License-Identifier: MIT
    Create by. Jacob 2022. 07. 07
*/
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract UpgradePolygon1155 is ERC1155URIStorageUpgradeable {

    mapping (uint256 => string) private _uris;

    /*
        디폴트로 넣어두는 TOKEN URI
    */
    function initialize() initializer public {
        __ERC1155_init("https://denaissance.mypinata.cloud/ipfs/{id}");
    }

    /*
        블록에 기록할 이벤트 생성
    */
    event assetInformation (
        uint256 indexed tokenId,
        string tokenUri
    );

    /*
        MINTING 전용 함수
    */
    function setMint(address _creator,uint256 _tokenId, uint256 _quantity) public {
        _mint(_creator, _tokenId, _quantity, "");
    }

    /*
        발행하는 토큰의 토큰 URI를 덮어씌워 준다.
    */
    function uri(uint256 tokenId) override public view returns (string memory) {
        return (_uris[tokenId]);
    }

    /* 
        발행한 TOKEN URI를 TOKEN ID와 맵핑해서 저장 해준다.
    */ 
    function setTokenUri(uint256 _tokenId, string memory _uri) public {
        require(bytes(_uris[_tokenId]).length == 0, "Cannot set uri twice");

        _uris[_tokenId] = _uri; 
    }

    /*
        구매 전용 함수     
    */
    function setOrder(
        bool _isFirst,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _totalQuantity,
        uint256 _createFee,
        uint256 _serviceFee,
        uint256 _sellerPrice,
        address _seller,
        address _creator,
        address _serviceOwner,
        string memory _tokenUri
    ) public payable returns (uint256) {
        /*
            첫번째로 구매하는 사람은 Create address로 민팅을 해준다.
        */
        if (_isFirst) {
            setMint(_seller, _tokenId, _totalQuantity);
            setTokenUri(_tokenId, _tokenUri);
        }
        
        /*
            구매자에게 수량 만큼 asset을 전송
        */
        _safeTransferFrom(_seller, msg.sender, _tokenId, _quantity, "0x00");

        /*
            Create Fee 분배
            0% 일때는 그냥 통과한다.
        */
        if (_createFee > 0) {
            payable(_creator).transfer(_createFee);
        }

        /*
            Service Fee -> 2.5% 분배
            Seller에게는 판매가
            (크리에이터 수수료 - 서비스 수수료) 계산 후 전송
        */
        payable(_seller).transfer(_sellerPrice);
        payable(_serviceOwner).transfer(_serviceFee);
        

        /* 해당 거래를 블록에 기록해 준다. */
        emit assetInformation (
            _tokenId,
            _tokenUri
        );

        return _tokenId;
    }

    /*
        원화 전용 함수     
    */
    function setKRWOrder(
        bool _isFirst,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _totalQuantity,
        address _seller,
        string memory _tokenUri
    ) public payable returns (uint256) {
        /*
            첫번째로 구매하는 사람은 Create address로 민팅을 해준다.
        */
        if (_isFirst) {
            setMint(_seller, _tokenId, _totalQuantity);
            setTokenUri(_tokenId, _tokenUri);
        }
        
        /*
            구매자에게 수량 만큼 asset을 전송
        */
        _safeTransferFrom(_seller, msg.sender, _tokenId, _quantity, "0x00");

        /* 해당 거래를 블록에 기록해 준다. */
        emit assetInformation (
            _tokenId,
            _tokenUri
        );

        return _tokenId;
    }
}