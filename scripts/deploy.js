const hre = require("hardhat");

async function main() {
    console.log("Deploying Complaints contract...");

    const Complaints = await hre.ethers.getContractFactory("Complaints");
    const complaints = await Complaints.deploy();

    await complaints.waitForDeployment();

    console.log(
        `Complaints contract deployed to: ${await complaints.getAddress()}`
    );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
