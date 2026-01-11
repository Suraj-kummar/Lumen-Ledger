const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Complaints", function () {
    let Complaints;
    let complaints;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        Complaints = await ethers.getContractFactory("Complaints");
        complaints = await Complaints.deploy();
    });

    describe("Submission", function () {
        it("Should allow a user to submit a complaint", async function () {
            const cid = "QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco";
            const dept = "Traffic";
            const category = "Corruption";

            await expect(complaints.connect(addr1).submitComplaint(cid, dept, category))
                .to.emit(complaints, "ComplaintSubmitted")
                .withArgs(1, addr1.address, cid);

            const complaint = await complaints.getComplaint(1);
            expect(complaint.complainant).to.equal(addr1.address);
            expect(complaint.cid).to.equal(cid);
            expect(complaint.status).to.equal(0); // Status.OPEN
        });
    });

    describe("Escalation", function () {
        const cid = "QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco";
        const dept = "Traffic";
        const category = "Corruption";

        beforeEach(async function () {
            await complaints.connect(addr1).submitComplaint(cid, dept, category);
        });

        it("Should fail to escalate before 7 days", async function () {
            await expect(complaints.triggerEscalation(1)).to.be.revertedWith(
                "Escalation period has not yet passed"
            );
        });

        it("Should allow anyone to escalate after 7 days", async function () {
            const SEVEN_DAYS = 7 * 24 * 60 * 60;
            await time.increase(SEVEN_DAYS + 1);

            await expect(complaints.connect(addr2).triggerEscalation(1))
                .to.emit(complaints, "ComplaintEscalated");

            const complaint = await complaints.getComplaint(1);
            expect(complaint.status).to.equal(3); // Status.ESCALATED
        });

        it("Should not allow escalation if status is not OPEN", async function () {
            const SEVEN_DAYS = 7 * 24 * 60 * 60;
            await time.increase(SEVEN_DAYS + 1);

            await complaints.updateStatus(1, 1); // Status.IN_PROGRESS

            await expect(complaints.triggerEscalation(1)).to.be.revertedWith(
                "Only open complaints can be escalated"
            );
        });
    });

    describe("Status Updates", function () {
        it("Should only allow admin to update status", async function () {
            await complaints.connect(addr1).submitComplaint("cid", "dept", "cat");

            await expect(
                complaints.connect(addr1).updateStatus(1, 1)
            ).to.be.revertedWith("Only admin can perform this action");

            await expect(
                complaints.connect(owner).updateStatus(1, 1)
            ).to.emit(complaints, "StatusUpdated");
        });
    });
});
