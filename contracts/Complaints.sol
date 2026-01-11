// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Decentralized Complaint System (DCS)
 * @author Senior Developer
 * @notice A censorship-resistant system for lodging and tracking public complaints.
 */
contract Complaints {
    enum Status { OPEN, IN_PROGRESS, RESOLVED, ESCALATED }

    struct Complaint {
        uint256 id;
        address complainant;
        string cid; // IPFS hash of the data
        string department;
        string category;
        uint256 timestamp;
        Status status;
        address assignedOfficial;
    }

    uint256 public complaintCount;
    mapping(uint256 => Complaint) public complaints;
    mapping(address => uint256[]) public userComplaints;

    // Time constants
    uint256 public constant ESCALATION_PERIOD = 7 days;

    // Access Control (Simplistic for MVP)
    address public admin;

    event ComplaintSubmitted(uint256 indexed id, address indexed complainant, string cid);
    event StatusUpdated(uint256 indexed id, Status oldStatus, Status newStatus);
    event ComplaintEscalated(uint256 indexed id, uint256 timestamp);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Submit a new complaint.
     * @param _cid The IPFS Content ID of the complaint data.
     * @param _department The department name (e.g., "Police", "Public Works").
     * @param _category The category of grievance (e.g., "Corruption", "Maintenance").
     */
    function submitComplaint(
        string memory _cid,
        string memory _department,
        string memory _category
    ) external returns (uint256) {
        complaintCount++;
        
        complaints[complaintCount] = Complaint({
            id: complaintCount,
            complainant: msg.sender,
            cid: _cid,
            department: _department,
            category: _category,
            timestamp: block.timestamp,
            status: Status.OPEN,
            assignedOfficial: address(0)
        });

        userComplaints[msg.sender].push(complaintCount);

        emit ComplaintSubmitted(complaintCount, msg.sender, _cid);
        return complaintCount;
    }

    /**
     * @notice Update the status of a complaint. 
     * @dev Only authorized officials (or admin for MVP) can update status.
     * @param _id The unique ID of the complaint.
     * @param _newStatus The new status to transition to.
     */
    function updateStatus(uint256 _id, Status _newStatus) external onlyAdmin {
        Complaint storage c = complaints[_id];
        require(c.id != 0, "Complaint does not exist");
        require(c.status != Status.RESOLVED, "Already resolved");
        require(c.status != Status.ESCALATED, "Already escalated");

        Status oldStatus = c.status;
        c.status = _newStatus;

        emit StatusUpdated(_id, oldStatus, _newStatus);
    }

    /**
     * @notice Publicly callable function to trigger escalation if conditions are met.
     * @dev This is the core "Censorship Resistance" feature.
     * @param _id The ID of the complaint to escalate.
     */
    function triggerEscalation(uint256 _id) external {
        Complaint storage c = complaints[_id];
        require(c.id != 0, "Complaint does not exist");
        require(c.status == Status.OPEN, "Only open complaints can be escalated");
        
        // Technical check for "Admin God Mode" prevention
        require(
            block.timestamp >= c.timestamp + ESCALATION_PERIOD,
            "Escalation period has not yet passed"
        );

        c.status = Status.ESCALATED;

        emit ComplaintEscalated(_id, block.timestamp);
    }

    /**
     * @notice Retrieve details of a specific complaint.
     */
    function getComplaint(uint256 _id) external view returns (Complaint memory) {
        return complaints[_id];
    }

    /**
     * @notice Get all complaint IDs submitted by a specific user.
     */
    function getUserComplaints(address _user) external view returns (uint256[] memory) {
        return userComplaints[_user];
    }
}
