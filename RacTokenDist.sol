//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.8;
import "@openzeppelin/contracts/math/SafeMath.sol";



interface IERC20{
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract RacOsTokenDistributor{

    using SafeMath for uint256;

     // subscribe() will take in a uint for any of this
    // 1 will represent Basic
    // 2 will represent Premium
    // 3 will represent VIP
    mapping(address => uint256 ) public subscriptionType;

    mapping(uint256 => uint256) public claimableTokensPerSubType;

    mapping(address => uint256) public claimedDateInterval;



    event Subscribe(address indexed user, uint256 indexed subTpe);
    event Claimed(address indexed user, uint256 amountClaimed);

    IERC20 racInstance = IERC20(0x3e3A8476Fb909049a751838552DbfCd21C77D387);

    address admin;
    // blackList mapping check
    mapping(address => bool) public isBlackListed;

    modifier onlyAdmin(){
        require(msg.sender == admin, "only admin can do this");
        _;
    }

    // takes in uint256 as subscription type- this will range only from 1-3
    function subscribe(uint256 _subscriptionType) public {
        require(isBlackListed[msg.sender] == false, "you have been blackListed, kindly reach out to the admin if you think something is wrong");
        require(_subscriptionType == 1 || _subscriptionType == 2 || _subscriptionType == 3, "number passed not within subscription range");
        subscriptionType[msg.sender] =_subscriptionType;

        emit Subscribe(msg.sender, _subscriptionType);
    }

    function setClaimableTokenPerSub(uint256 subType, uint256 _amountClaimable) public{
        
        claimableTokensPerSubType[subType] = _amountClaimable;
    }

    //admin can choose
    function blackList(address _user) public onlyAdmin{
        isBlackListed[_user] = true;
    }

    // admin can remove an address from blackList
    function removeFromBlackList(address _user) public {
        require(isBlackListed[_user] == true, "this address is currently not blackListed");
        isBlackListed[_user] = false;
    }


    function claimRacForTheMonth() public{
        require(subscriptionType[msg.sender] == 1 || subscriptionType[msg.sender] == 2 || subscriptionType[msg.sender] == 3, "You do not have a valid subscription on this platform");
        require(isBlackListed[msg.sender] == false, "you are currently blackListed from claiming, Please contact admin");
        require(block.timestamp.sub(claimedDateInterval[msg.sender]) >= 120, "Not yet time");

        //check user sub type to determine how much token to claimable
        uint256 userSubType = subscriptionType[msg.sender];

        // update time for user
        claimedDateInterval[msg.sender] = block.timestamp.add(120);

        // use userSubType to check how much claimableTokensPerSub token
        racInstance.transfer(msg.sender, claimableTokensPerSubType[userSubType]);


        emit Claimed(msg.sender, claimableTokensPerSubType[userSubType]);


    }

    

    
}