const Mint = artifacts.require("Mint");
const N2DRewards = artifacts.require("N2DRewards");
const test = artifacts.require("test");

contract("test", (accounts) => {
    it("should say something", async() => {
        const testInstance = await test.deployed();
        testInstance.testExtract(["SE7EN_Mood_5", "Signature_pose_2"])
        testInstance.getPoseMood(1);
    });
})