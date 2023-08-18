pragma solidity ^0.8.13;

contract MockOracle {
    uint256 public forceAnswer;

    function setAnswer(uint256 _answer) external {
        forceAnswer = _answer;
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (1, int256(forceAnswer), block.timestamp, block.timestamp, 1);
    }
}
