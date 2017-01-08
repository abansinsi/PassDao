import "PassManager.sol";

pragma solidity ^0.4.6;

/*
This file is part of Pass DAO.

Pass DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Pass DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with Pass DAO.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
Smart contract for a Decentralized Autonomous Organization (DAO)
to automate organizational governance and decision-making.
*/

/// @title Pass Decentralized Autonomous Organisation
contract PassDaoInterface {

    struct BoardMeeting {        
        // Address of the creator of the board meeting for a proposal
        address creator;  
        // Index to identify the proposal to pay a contractor or fund the Dao
        uint proposalID;
        // Index to identify the proposal to update the Dao rules 
        uint daoRulesProposalID; 
        // unix timestamp, denoting the end of the set period of a proposal before the board meeting 
        uint setDeadline;
        // Fees (in wei) paid by the creator of the board meeting
        uint fees;
        // Total of fees (in wei) rewarded to the voters or to the Dao account manager for the balance
        uint totalRewardedAmount;
        // A unix timestamp, denoting the end of the voting period
        uint votingDeadline;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool open; 
        // A unix timestamp, denoting the date of the execution of the approved proposal
        uint dateOfExecution;
        // Number of shares in favor of the proposal
        uint yea; 
        // Number of shares opposed to the proposal
        uint nay; 
        // mapping to indicate if a shareholder has voted
        mapping (address => bool) hasVoted;  
    }

    struct Contractor {
        // The address of the contractor manager smart contract
        address contractorManager;
        // The date of the first order for the contractor
        uint creationDate;
    }
        
    struct Proposal {
        // Index to identify the board meeting of the proposal
        uint boardMeetingID;
        // The contractor manager smart contract
        PassManager contractorManager;
        // The index of the contractor proposal
        uint contractorProposalID;
        // The amount (in wei) of the proposal
        uint amount; 
        // True if the proposal foresees a contractor token creation
        bool tokenCreation;
        // True if public funding without a main partner
        bool publicShareCreation; 
        // The address which sets partners and manages the funding in case of private funding
        address mainPartner;
        // The initial price multiplier of Dao shares at the beginning of the funding
        uint initialSharePriceMultiplier; 
        // The inflation rate to calculate the actual contractor share price
        uint inflationRate;
        // A unix timestamp, denoting the start time of the funding
        uint minutesFundingPeriod;
        // True if the proposal is closed
        bool open; 
    }

    struct Rules {
        // Index to identify the board meeting that decides to apply or not the Dao rules
        uint boardMeetingID;  
        // The quorum needed for each proposal is calculated by totalSupply / minQuorumDivisor
        uint minQuorumDivisor;  
        // Minimum fees (in wei) to create a proposal
        uint minBoardMeetingFees; 
        // Period in minutes to consider or set a proposal before the voting procedure
        uint minutesSetProposalPeriod; 
        // The minimum debate period in minutes that a generic proposal can have
        uint minMinutesDebatePeriod;
        // The inflation rate to calculate the reward of fees to voters during a board meeting 
        uint feesRewardInflationRate;
        // True if the dao rules allow the transfer of shares
        bool transferable;
        // Address of the effective Dao smart contract (can be different of this Dao in case of upgrade)
        address dao;
    } 
    
    // The creator of the Dao
    address public creator;
    // The name of the project
    string public projectName;
    // The address of the last Dao before upgrade (not mandatory)
    address public lastDao;
    // End date of the setup procedure
    uint public smartContractStartDate;
    // The Dao manager smart contract
    PassManager public daoManager;
    // The minimum periods in minutes 
    uint public minMinutesPeriods;
    // The maximum period in minutes for proposals (set+debate)
    uint public maxMinutesProposalPeriod;
    // The maximum funding period in minutes for funding proposals
    uint public maxMinutesFundingPeriod;
    // The maximum inflation rate for share price or rewards to voters
    uint public maxInflationRate;
    
    // Map to allow the share holders to withdraw board meeting fees
    mapping (address => uint) pendingFees;

    // Board meetings to vote for or against a proposal
    BoardMeeting[] public BoardMeetings; 
    // Contractors of the Dao
    Contractor[] public Contractors;
    // Map with the indexes of the contractors
    mapping (address => uint) contractorID;
    // Proposals to pay a contractor or fund the Dao
    Proposal[] public Proposals;
    // Proposals to update the Dao rules
    Rules[] public DaoRulesProposals;
    // The current Dao rules
    Rules public DaoRules; 
    
    /// @dev The constructor function
    /// @param _projectName The name of the Dao
    /// @param _lastDao The address of the last Dao before upgrade (not mandatory)
    //function PassDao(
    //    string _projectName,
    //    address _lastDao);
    
    /// @dev Internal function to add a new contractor
    /// @param _contractorManager The address of the contractor manager
    /// @param _creationDate The date of the first order
    function addContractor(address _contractorManager, uint _creationDate) internal;

    /// @dev Function to clone a contractor from the last Dao in case of upgrade 
    /// @param _contractorManager The address of the contractor manager
    /// @param _creationDate The date of the first order
    function cloneContractor(address _contractorManager, uint _creationDate);
    
    /// @notice Function to update the client of the contractor managers in case of upgrade
    /// @param _from The index of the first contractor manager to update
    /// @param _to The index of the last contractor manager to update
    function updateClientOfContractorManagers(
        uint _from, 
        uint _to);

    /// @dev Function to initialize the Dao
    /// @param _daoManager Address of the Dao manager smart contract
    /// @param _maxInflationRate The maximum inflation rate for contractor and funding proposals
    /// @param _minMinutesPeriods The minimum periods in minutes
    /// @param _maxMinutesFundingPeriod The maximum funding period in minutes for funding proposals
    /// @param _maxMinutesProposalPeriod The maximum period in minutes for proposals (set+debate)
    /// @param _minQuorumDivisor The initial minimum quorum divisor for the proposals
    /// @param _minBoardMeetingFees The amount (in wei) to make a proposal and ask for a board meeting
    /// @param _minutesSetProposalPeriod The minimum period in minutes before a board meeting
    /// @param _minMinutesDebatePeriod The minimum period in minutes of the board meetings
    /// @param _feesRewardInflationRate The inflation rate to calculate the reward of fees to voters during a board meeting
    function initDao(
        address _daoManager,
        uint _maxInflationRate,
        uint _minMinutesPeriods,
        uint _maxMinutesFundingPeriod,
        uint _maxMinutesProposalPeriod,
        uint _minQuorumDivisor,
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate
        );
        
    /// @dev Internal function to create a board meeting
    /// @param _proposalID The index of the proposal if for a contractor or for a funding
    /// @param _daoRulesProposalID The index of the proposal if Dao rules
    /// @param _minutesDebatingPeriod The duration in minutes of the meeting
    /// @return the index of the board meeting
    function newBoardMeeting(
        uint _proposalID, 
        uint _daoRulesProposalID, 
        uint _minutesDebatingPeriod
    ) internal returns (uint);
    
    /// @notice Function to make a proposal to pay a contractor or fund the Dao
    /// @param _contractorManager Address of the contractor manager smart contract
    /// @param _contractorProposalID Index of the contractor proposal of the contractor manager
    /// @param _amount The amount (in wei) of the proposal
    /// @param _tokenCreation True if the proposal foresees a contractor token creation
    /// @param _publicShareCreation True if public funding without a main partner
    /// @param _mainPartner The address which sets partners and manage the funding 
    /// in case of private funding (not mandatory)
    /// @param _initialSharePriceMultiplier The initial price multiplier of shares
    /// @param _inflationRate If 0, the share price doesn't change during the funding (not mandatory)
    /// @param _minutesFundingPeriod Period in minutes of the funding
    /// @param _minutesDebatingPeriod Period in minutes of the board meeting to vote on the proposal
    /// @return The index of the proposal
    function newProposal(
        address _contractorManager,
        uint _contractorProposalID,
        uint _amount, 
        bool _publicShareCreation,
        bool _tokenCreation,
        address _mainPartner,
        uint _initialSharePriceMultiplier, 
        uint _inflationRate,
        uint _minutesFundingPeriod,
        uint _minutesDebatingPeriod
    ) payable returns (uint);

    /// @notice Function to make a proposal to change the Dao rules 
    /// @param _minQuorumDivisor If 5, the minimum quorum is 20%
    /// @param _minBoardMeetingFees The amount (in wei) to make a proposal and ask for a board meeting
    /// @param _minutesSetProposalPeriod Minimum period in minutes before a board meeting
    /// @param _minMinutesDebatePeriod The minimum period in minutes of the board meetings
    /// @param _feesRewardInflationRate The inflation rate to calculate the reward of fees to voters during a board meeting
    /// @param _transferable True if the proposal foresees to allow the transfer of Dao shares
    /// @param _dao Address of a new Dao smart contract in case of upgrade (not mandatory)    
    /// @param _minutesDebatingPeriod Period in minutes of the board meeting to vote on the proposal
    function newDaoRulesProposal(
        uint _minQuorumDivisor, 
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        bool _transferable,
        address _dao,
        uint _minutesDebatingPeriod
    ) payable returns (uint);
    
    /// @notice Function to vote during a board meeting
    /// @param _boardMeetingID The index of the board meeting
    /// @param _supportsProposal True if the proposal is supported
    function vote(
        uint _boardMeetingID, 
        bool _supportsProposal
    );

    /// @notice Function to execute a board meeting decision and close the board meeting
    /// @param _boardMeetingID The index of the board meeting
    /// @return Whether the proposal was executed or not
    function executeDecision(uint _boardMeetingID) returns (bool);
    
    /// @notice Function to order a contractor proposal
    /// @param _proposalID The index of the proposal
    /// @return Whether the proposal was ordered and the proposal amount sent or not
    function orderContractorProposal(uint _proposalID) returns (bool);   

    /// @notice Function to withdraw the rewarded board meeting fees
    /// @return Whether the withdraw was successful or not    
    function withdrawBoardMeetingFees() returns (bool);

    /// @param _shareHolder Address of the shareholder
    /// @return The amount in wei the shareholder can withdraw    
    function PendingFees(address _shareHolder) constant returns (uint);
    
    /// @return The minimum quorum for proposals to pass 
    function minQuorum() constant returns (uint);

    /// @return The number of contractors 
   function numberOfContractors() constant returns (uint);

    /// @return The number of board meetings (or proposals) 
    function numberOfBoardMeetings() constant returns (uint);

    event ContractorProposalAdded(uint indexed ProposalID, uint boardMeetingID, address indexed ContractorManager, 
        uint indexed ContractorProposalID, uint amount);
    event FundingProposalAdded(uint indexed ProposalID, uint boardMeetingID, bool indexed LinkedToContractorProposal, 
        uint amount, address MainPartner, uint InitialSharePriceMultiplier, uint InflationRate, uint MinutesFundingPeriod);
    event DaoRulesProposalAdded(uint indexed DaoRulesProposalID, uint boardMeetingID, uint MinQuorumDivisor, 
        uint MinBoardMeetingFees, uint MinutesSetProposalPeriod, uint MinMinutesDebatePeriod, uint FeesRewardInflationRate, 
        bool Transferable, address NewDao);
    event Voted(uint indexed boardMeetingID, uint ProposalID, uint DaoRulesProposalID, bool position, address indexed voter);
    event ProposalClosed(uint indexed ProposalID, uint indexed DaoRulesProposalID, uint boardMeetingID, 
        uint FeesGivenBack, bool ProposalExecuted, uint BalanceSentToDaoManager);
    event SentToContractor(uint indexed ProposalID, uint indexed ContractorProposalID, address indexed ContractorManagerAddress, uint AmountSent);
    event Withdrawal(address indexed Recipient, uint Amount);
    event DaoUpgraded(address NewDao);
    
}

contract PassDao is PassDaoInterface {

    function PassDao(
        string _projectName,
        address _lastDao) {

        lastDao = _lastDao;
        creator = msg.sender;
        projectName =_projectName;

        Contractors.length = 1;
        BoardMeetings.length = 1;
        Proposals.length = 1;
        DaoRulesProposals.length = 1; 
        
    }
    
    function addContractor(address _contractorManager, uint _creationDate) internal {
        
        if (contractorID[_contractorManager] == 0) {

            uint _contractorID = Contractors.length++;
            Contractor c = Contractors[_contractorID];
            
            contractorID[_contractorManager] = _contractorID;
            c.contractorManager = _contractorManager;
            c.creationDate = _creationDate;
        }
        
    }
    
    function cloneContractor(address _contractorManager, uint _creationDate) {
        
        if (DaoRules.minQuorumDivisor != 0) throw;

        addContractor(_contractorManager, _creationDate);
        
    }
    
    function initDao(
        address _daoManager,
        uint _maxInflationRate,
        uint _minMinutesPeriods,
        uint _maxMinutesFundingPeriod,
        uint _maxMinutesProposalPeriod,
        uint _minQuorumDivisor,
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate
        ) {
            
        
        if (smartContractStartDate != 0) throw;

        maxInflationRate = _maxInflationRate;
        minMinutesPeriods = _minMinutesPeriods;
        maxMinutesFundingPeriod = _maxMinutesFundingPeriod;
        maxMinutesProposalPeriod = _maxMinutesProposalPeriod;
        
        DaoRules.minQuorumDivisor = _minQuorumDivisor;
        DaoRules.minBoardMeetingFees = _minBoardMeetingFees;
        DaoRules.minutesSetProposalPeriod = _minutesSetProposalPeriod;
        DaoRules.minMinutesDebatePeriod = _minMinutesDebatePeriod;
        DaoRules.feesRewardInflationRate = _feesRewardInflationRate;
        daoManager = PassManager(_daoManager);
        
        smartContractStartDate = now;
        
    }
    
    function updateClientOfContractorManagers(
        uint _from,
        uint _to) {
        
        if (_from < 1 || _to > Contractors.length - 1) throw;
        
        for (uint i = _from; i <= _to; i++) {
            PassManager(Contractors[i].contractorManager).updateClient(DaoRules.dao);
        }
        
    }
    
    function newBoardMeeting(
        uint _proposalID, 
        uint _daoRulesProposalID, 
        uint _minutesDebatingPeriod
    ) internal returns (uint) {

        if (msg.value < DaoRules.minBoardMeetingFees
            || DaoRules.minutesSetProposalPeriod + _minutesDebatingPeriod > maxMinutesProposalPeriod
            || now + ((DaoRules.minutesSetProposalPeriod + _minutesDebatingPeriod) * 1 minutes) < now
            || _minutesDebatingPeriod < DaoRules.minMinutesDebatePeriod
            || msg.sender == address(this)) throw;

        uint _boardMeetingID = BoardMeetings.length++;
        BoardMeeting b = BoardMeetings[_boardMeetingID];

        b.creator = msg.sender;

        b.proposalID = _proposalID;
        b.daoRulesProposalID = _daoRulesProposalID;

        b.fees = msg.value;
        
        b.setDeadline = now + (DaoRules.minutesSetProposalPeriod * 1 minutes);        
        b.votingDeadline = b.setDeadline + (_minutesDebatingPeriod * 1 minutes); 

        b.open = true; 

        return _boardMeetingID;

    }

    function newProposal(
        address _contractorManager,
        uint _contractorProposalID,
        uint _amount, 
        bool _tokenCreation,
        bool _publicShareCreation,
        address _mainPartner,
        uint _initialSharePriceMultiplier, 
        uint _inflationRate,
        uint _minutesFundingPeriod,
        uint _minutesDebatingPeriod
    ) payable returns (uint) {

        if ((_contractorManager != 0 && _contractorProposalID == 0)
            || (_contractorManager == 0 
                && (_initialSharePriceMultiplier == 0
                    || _contractorProposalID != 0)
            || (_tokenCreation && _publicShareCreation)
            || (_initialSharePriceMultiplier != 0
                && (_minutesFundingPeriod < minMinutesPeriods
                    || _inflationRate > maxInflationRate
                    || _minutesFundingPeriod > maxMinutesFundingPeriod)))) throw;

        uint _proposalID = Proposals.length++;
        Proposal p = Proposals[_proposalID];

        p.contractorManager = PassManager(_contractorManager);
        p.contractorProposalID = _contractorProposalID;
        
        p.amount = _amount;
        p.tokenCreation = _tokenCreation;

        p.publicShareCreation = _publicShareCreation;
        p.mainPartner = _mainPartner;
        p.initialSharePriceMultiplier = _initialSharePriceMultiplier;
        p.inflationRate = _inflationRate;
        p.minutesFundingPeriod = _minutesFundingPeriod;

        p.boardMeetingID = newBoardMeeting(_proposalID, 0, _minutesDebatingPeriod);   

        p.open = true;
        
        if (_contractorProposalID != 0) {
            ContractorProposalAdded(_proposalID, p.boardMeetingID, p.contractorManager, p.contractorProposalID, p.amount);
            if (_initialSharePriceMultiplier != 0) {
                FundingProposalAdded(_proposalID, p.boardMeetingID, true, p.amount, p.mainPartner, 
                    p.initialSharePriceMultiplier, _inflationRate, _minutesFundingPeriod);
            }
        }
        else if (_initialSharePriceMultiplier != 0) {
                FundingProposalAdded(_proposalID, p.boardMeetingID, false, p.amount, p.mainPartner, 
                    p.initialSharePriceMultiplier, _inflationRate, _minutesFundingPeriod);
        }

        return _proposalID;
        
    }

    function newDaoRulesProposal(
        uint _minQuorumDivisor, 
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        bool _transferable,
        address _newDao,
        uint _minutesDebatingPeriod
    ) payable returns (uint) {
    
        if (_minQuorumDivisor <= 1
            || _minQuorumDivisor > 10
            || _minutesSetProposalPeriod < minMinutesPeriods
            || _minMinutesDebatePeriod < minMinutesPeriods
            || _minutesSetProposalPeriod + _minMinutesDebatePeriod > maxMinutesProposalPeriod
            || _feesRewardInflationRate > maxInflationRate
            ) throw; 
        
        uint _DaoRulesProposalID = DaoRulesProposals.length++;
        Rules r = DaoRulesProposals[_DaoRulesProposalID];

        r.minQuorumDivisor = _minQuorumDivisor;
        r.minBoardMeetingFees = _minBoardMeetingFees;
        r.minutesSetProposalPeriod = _minutesSetProposalPeriod;
        r.minMinutesDebatePeriod = _minMinutesDebatePeriod;
        r.feesRewardInflationRate = _feesRewardInflationRate;
        r.transferable = _transferable;
        r.dao = _newDao;

        r.boardMeetingID = newBoardMeeting(0, _DaoRulesProposalID, _minutesDebatingPeriod);     

        DaoRulesProposalAdded(_DaoRulesProposalID, r.boardMeetingID, _minQuorumDivisor, _minBoardMeetingFees, 
            _minutesSetProposalPeriod, _minMinutesDebatePeriod, _feesRewardInflationRate ,_transferable, _newDao);

        return _DaoRulesProposalID;
        
    }
    
    function vote(
        uint _boardMeetingID, 
        bool _supportsProposal
    ) {
        
        BoardMeeting b = BoardMeetings[_boardMeetingID];

        if (b.hasVoted[msg.sender] 
            || now < b.setDeadline
            || now > b.votingDeadline) throw;

        uint _balance = uint(daoManager.balanceOf(msg.sender));
        if (_balance == 0) throw;
        
        b.hasVoted[msg.sender] = true;

        if (_supportsProposal) b.yea += _balance;
        else b.nay += _balance; 

        if (b.fees > 0 && b.proposalID != 0 && Proposals[b.proposalID].contractorProposalID != 0) {

            uint _a = 100*b.fees;
            if ((_a/100 != b.fees) || ((_a*_balance)/_a != _balance)) throw;
            uint _multiplier = (_a*_balance)/uint(daoManager.totalSupply());

            uint _divisor = 100 + 100*DaoRules.feesRewardInflationRate*(now - b.setDeadline)/(100*365 days);

            uint _rewardedamount = _multiplier/_divisor;
            
            if (b.totalRewardedAmount + _rewardedamount > b.fees) _rewardedamount = b.fees - b.totalRewardedAmount;
            b.totalRewardedAmount += _rewardedamount;
            pendingFees[msg.sender] += _rewardedamount;
        }

        Voted(_boardMeetingID, b.proposalID, b.daoRulesProposalID, _supportsProposal, msg.sender);
        
        daoManager.blockTransfer(msg.sender, b.votingDeadline);

    }

    function executeDecision(uint _boardMeetingID) returns (bool) {

        BoardMeeting b = BoardMeetings[_boardMeetingID];
        Proposal p = Proposals[b.proposalID];
        
        if (now < b.votingDeadline || !b.open) throw;
        
        b.open = false;
        if (p.contractorProposalID == 0) p.open = false;

        uint _fees;
        uint _minQuorum = minQuorum();

        if (b.fees > 0
            && (b.proposalID == 0 || p.contractorProposalID == 0)
            && b.yea + b.nay >= _minQuorum) {
                    _fees = b.fees;
                    b.fees = 0;
                    pendingFees[b.creator] += _fees;
        }        

        uint _balance = b.fees - b.totalRewardedAmount;
        if (_balance > 0) {
            if (!daoManager.send(_balance)) throw;
        }
        
        if (b.yea + b.nay < _minQuorum || b.yea <= b.nay) {
            p.open = false;
            ProposalClosed(b.proposalID, b.daoRulesProposalID, _boardMeetingID, _fees, false, _balance);
            return;
        }

        b.dateOfExecution = now;

        if (b.proposalID != 0) {
            
            if (p.initialSharePriceMultiplier != 0) {

                daoManager.setFundingRules(p.mainPartner, p.publicShareCreation, p.initialSharePriceMultiplier, 
                    p.amount, p.minutesFundingPeriod, p.inflationRate, b.proposalID);

                if (p.contractorProposalID != 0 && p.tokenCreation) {
                    p.contractorManager.setFundingRules(p.mainPartner, p.publicShareCreation, 0, 
                        p.amount, p.minutesFundingPeriod, maxInflationRate, b.proposalID);
                }

            }
            
        } else {

            Rules r = DaoRulesProposals[b.daoRulesProposalID];
            DaoRules.boardMeetingID = r.boardMeetingID;

            DaoRules.minQuorumDivisor = r.minQuorumDivisor;
            DaoRules.minMinutesDebatePeriod = r.minMinutesDebatePeriod; 
            DaoRules.minBoardMeetingFees = r.minBoardMeetingFees;
            DaoRules.minutesSetProposalPeriod = r.minutesSetProposalPeriod;
            DaoRules.feesRewardInflationRate = r.feesRewardInflationRate;

            DaoRules.transferable = r.transferable;
            if (r.transferable) daoManager.ableTransfer();
            else daoManager.disableTransfer();
            
            if ((r.dao != 0) && (r.dao != address(this))) {
                DaoRules.dao = r.dao;
                daoManager.updateClient(r.dao);
                DaoUpgraded(r.dao);
            }

        }

        ProposalClosed(b.proposalID, b.daoRulesProposalID, _boardMeetingID ,_fees, true, _balance);
            
        return true;
        
    }
    
    function orderContractorProposal(uint _proposalID) returns (bool) {
        
        Proposal p = Proposals[_proposalID];
        BoardMeeting b = BoardMeetings[p.boardMeetingID];

        if (b.open || !p.open) throw;
        
        uint _amount = p.amount;

        if (p.initialSharePriceMultiplier != 0) {
            _amount = daoManager.FundedAmount(_proposalID);
            if (_amount == 0 && now < b.dateOfExecution + (p.minutesFundingPeriod * 1 minutes)) return;
        }
        
        p.open = false;   

        if (_amount == 0 || !p.contractorManager.order(_proposalID, p.contractorProposalID, _amount)) return;
        
        if (!daoManager.sendTo(p.contractorManager, _amount)) throw;
        SentToContractor(_proposalID, p.contractorProposalID, address(p.contractorManager), _amount);
        
        addContractor(address(p.contractorManager), now);
        
        return true;

    }
    
    function withdrawBoardMeetingFees() returns (bool) {

        uint _amount = pendingFees[msg.sender];

        pendingFees[msg.sender] = 0;

        if (msg.sender.send(_amount)) {
            Withdrawal(msg.sender, _amount);
            return true;
        } else {
            pendingFees[msg.sender] = _amount;
            return false;
        }

    }

    function PendingFees(address _shareHolder) constant returns (uint) {
        return (pendingFees[_shareHolder]);
    }
    
    function minQuorum() constant returns (uint) {
        return (uint(daoManager.totalSupply()) / DaoRules.minQuorumDivisor);
    }

    function numberOfContractors() constant returns (uint) {
        return Contractors.length - 1;
    }
    
    function numberOfBoardMeetings() constant returns (uint) {
        return BoardMeetings.length - 1;
    }
    
}
