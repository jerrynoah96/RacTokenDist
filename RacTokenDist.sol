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

    mapping(address => bool) public isWhiteListed;

    mapping(address => bool) public hasClaimedForTheMonth;



    event Subscribe(address indexed user, uint256 indexed subType);
    event Claimed(address indexed user, uint256 amountClaimed);

    IERC20 racInstance = IERC20(0xFAC774043c5786e0f97De5FEDcFE4F2a175626b0);

    address admin =  0x134d255b124eAAb8C9790EdF10E0Cd603ff22b55;
   

    modifier onlyAdmin(){
        require(msg.sender == admin, "only admin can do this");
        _;
    }

    // takes in uint256 as subscription type- this will range only from 1-3
    function batchWhitelist(address[] memory _users, uint256[] memory _subscriptionType) public onlyAdmin {
        require(_users.length == _subscriptionType.length, "users and subscriptionType lenght mismatch");
        for(uint256 i=0; i < _users.length; i++ ){
        require(_subscriptionType[i] == 1 || _subscriptionType[i] == 2 || _subscriptionType[i] == 3, "number passed not within subscription range");
        subscriptionType[_users[i]] =_subscriptionType[i];
        isWhiteListed[_users[i]] = true;
        hasClaimedForTheMonth[_users[i]] = false;

        emit Subscribe(_users[i], _subscriptionType[i]);
        }
         
    }

    function setClaimableTokenPerSub(uint256 subType, uint256 _amountClaimable) public onlyAdmin{
        
        claimableTokensPerSubType[subType] = _amountClaimable;
    }

    
    function removeUsers(address[] memory _usersToRemove) public onlyAdmin{
        for(uint i=0; i<_usersToRemove.length; i++){
            isWhiteListed[_usersToRemove[i]] = false;
            subscriptionType[_usersToRemove[i]] = 0;
        }
        
    }

    

    function claimRacForTheMonth() public {
        require(isWhiteListed[msg.sender] == true, "you are currently not part of the whiteListed addresses");
        require(subscriptionType[msg.sender] == 1 || subscriptionType[msg.sender] == 2 || subscriptionType[msg.sender] == 3, "You do not have a valid subscription on this platform");
        require(hasClaimedForTheMonth[msg.sender] == false, "you have claimed already, kindly wait to be whiteListed for another round");
        
        //check user sub type to determine how much token to claimable
        uint256 userSubType = subscriptionType[msg.sender];

        // change mapping to true that address has claimedDateInterval
        hasClaimedForTheMonth[msg.sender] = true;

        // change subscription type to 0
        subscriptionType[msg.sender] = 0;

        // use userSubType to check how much claimableTokensPerSub token
        racInstance.transfer(msg.sender, claimableTokensPerSubType[userSubType]);

        emit Claimed(msg.sender, claimableTokensPerSubType[userSubType]);


    }

    

    
}