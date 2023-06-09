// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KCONUT is ERC20, Ownable {
    event AddConfirmer (address account);
    event RemoveConfirmer (address account);
    event Confirmed (address account, uint256 confirmedTime);

    struct ConfirmInfo {
        bool confirmed;
        uint256 validTime;
    }
    
    mapping(address => ConfirmInfo) private _confirmInfos;

    address[] public _confirmers;

    /*
        구매정보
    */
    event orderInformation (
        string indexed nftTxId, 
        address seller, 
        address buyer,
        uint256 serviceFee, 
        uint256 createFee,
        uint256 sellerPrice 
    );

    constructor(address confirmer1, address confirmer2) ERC20("CONUTK", "CONUTK") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());

        _confirmers.push(msg.sender);
        _confirmers.push(confirmer1);
        _confirmers.push(confirmer2);
        _resetConfirmed();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount * 10 ** decimals());
    }

    modifier isConfirmed() {
        require(!_checkConfirmed(), "Insufficient execution conditions.");
        _;
    }

    modifier isConfirmer(address walletAddress) {
        require(_checkConfirmer(walletAddress), "This address or caller is not the confirmer.");
        _;
    }

    function _checkConfirmed() 
        internal
        view
        returns (bool)
    {
        uint8 confirmedCount = 0;
        for (uint8 i = 0; i < _confirmers.length; i++) {
            if (_confirmInfos[_confirmers[i]].confirmed == true 
                && _confirmInfos[_confirmers[i]].validTime > block.timestamp) 
            {
                confirmedCount++;
            }
        }

        if (confirmedCount > 1) return true;
        else return false;
    }

    function _checkConfirmer(address walletAddress)
        public 
        view
        returns (bool)
    {
        for (uint8 i = 0; i < _confirmers.length; i++) {
            if (_confirmers[i] == walletAddress) {
                return true;
            }
        }

        return false;
    }    

    function addConfirmer(address walletAddress) 
        public
        isConfirmed
    {
        require(!_checkConfirmer(walletAddress), "Aleady exist confirmer.");

        _confirmers.push(walletAddress);
        _resetConfirmed();

        emit AddConfirmer(walletAddress);
    }

    function removeConfirmer(address walletAddress)
        public
        isConfirmed
        isConfirmer(walletAddress)
    {
        require(_confirmers.length > 3, "Must be at least 3 confirmers.");
        uint8 j = 0;
        for (uint8 i = 0; i < _confirmers.length; i++) {
            if (_confirmers[i] != walletAddress) {
                _confirmers[j] = _confirmers[i];
                j++;
            } else if (_confirmers[i] == walletAddress){
                delete _confirmers[i];
                delete _confirmInfos[_confirmers[i]];
            }
        }

        _confirmers.pop();
        _resetConfirmed();

        emit RemoveConfirmer (walletAddress);
    }

    function _resetConfirmed()
        internal
    {
        require((_checkConfirmer(msg.sender) || msg.sender == owner()), "Caller is not the owner or confirmer.");
        for (uint8 i = 0; i < _confirmers.length; i++) {
            _confirmInfos[_confirmers[i]].confirmed = false;
            _confirmInfos[_confirmers[i]].validTime = block.timestamp;
        }     
    }

    function toConfirm()
        public
        isConfirmer(msg.sender)
    {
        _confirmInfos[msg.sender].confirmed = true;
        _confirmInfos[msg.sender].validTime = block.timestamp + 86400;

        emit Confirmed(msg.sender, block.timestamp);
    }

    function getConfirmer() 
        public
        view
        isConfirmed
        returns (address[] memory) 
    {
        return (_confirmers);
    }

    function getConfirmed(address walletAddress) 
        public
        view
        isConfirmed
        returns (bool, uint256)
    {
        return (_confirmInfos[walletAddress].confirmed, _confirmInfos[walletAddress].validTime);
    }

    function conutsSwap(address to, uint256 amount) 
        public
        isConfirmed 
    {
        // decimals 단위 계산 적용해서 자산을 배분해 준다.
        transfer(to, amount);
    }

    function conutsTransferFrom(address from, address to, uint256 amount)
        public 
        isConfirmed
    {
        // 출금 가능한 한도 설정 풀어주기
        _approve(from, msg.sender, allowance(from, msg.sender) + amount);
        
        // 자산 전달해주기
        transferFrom(from, to, amount);
    }

    function getConuts(address account) 
        public 
        view 
        returns (uint256)
    {
        uint256 balance = balanceOf(account) / 10 ** decimals();

        return balance;
    }

    function orderTransfer(
        string memory nftTxId,
        address seller,
        address buyer,
        address creator,
        uint256 totalPrice,
        uint256 sellerPrice,
        uint256 serviceFee,
        uint256 createFee
    ) 
        public
        isConfirmed
    {
        require((_checkConfirmer(msg.sender) || msg.sender == owner()), "Caller is not the confirmer.");
        require(bytes(nftTxId).length > 0, "nftTxId is not correct.");
        require(balanceOf(buyer) > totalPrice, "Not enough KCONUT.");
        require(totalPrice > 0, "The purchase price must be greater than or equal to zero.");
        require(sellerPrice + serviceFee + createFee == totalPrice, "The purchase price does not match.");

        // Platform Royalty 차감
        conutsTransferFrom(buyer, seller, serviceFee);

        if (serviceFee > 0) {
            // Creator Royalty 차감
            conutsTransferFrom(buyer, seller, createFee);
        }
        
        // 판매자에게 KCONUT 전달
        conutsTransferFrom(buyer, creator, sellerPrice);

        /* 해당 거래를 블록에 기록해 준다. */
        emit orderInformation (
            nftTxId, // nft컨트렉 TX ID
            seller, // 판매자 주소
            buyer, // 구매자 주소
            serviceFee, // 플랫폼 수수료
            createFee, // 크리에이터 수수료
            sellerPrice // 판매자 수익
        );
    }
}