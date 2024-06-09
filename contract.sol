// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract QuizMatch {
    address public owner;

    struct Match {
        address[] users;
    }

    mapping(string => Match) internal matches;
    mapping(string => mapping(address => string)) internal userQuestions;

    event QuestionAttempted(string matchId, address userId, string questionId);
    event MatchCompleted(string matchId);
    event UserAddedToMatch(string matchId, address userId, string questionIds);
    event scoreSubmitted(string matchId, address userId, string score);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = 0x5Ff8121a6e761396d9F5B0B7A27E40235a9747Bd;
    }

    function addUserToMatch(string memory matchId, address userId, string memory questions) public onlyOwner {
        Match storage matchEntry = matches[matchId];
        userQuestions[matchId][userId] = questions;
        matchEntry.users.push(userId);
        emit UserAddedToMatch(matchId, userId, questions);
    }

    function deleteMatch(string memory matchId) public onlyOwner {
        Match storage matchEntry = matches[matchId];

        for (uint256 i = 0; i < matchEntry.users.length; i++) {
            delete userQuestions[matchId][matchEntry.users[i]];
        }
        
        delete matches[matchId];
        emit MatchCompleted(matchId);
    }

    function attemptQuestion(string memory matchId, string memory questionId) public {
        require(bytes(userQuestions[matchId][msg.sender]).length != 0, "User not found in match");

        userQuestions[matchId][msg.sender] = removeQuestionId(userQuestions[matchId][msg.sender], questionId);
        emit QuestionAttempted(matchId, msg.sender, questionId);
    }

    function submitScore(string memory matchId, address userId, string memory score) public onlyOwner{
        emit scoreSubmitted(matchId, userId, score);
    }

    function removeQuestionId(string memory questions, string memory questionId) internal pure returns (string memory) {
        bytes memory questionsBytes = bytes(questions);
        bytes memory questionIdBytes = bytes(questionId);

        bytes memory result = "";
        uint256 questionIdLength = questionIdBytes.length;
        bool found;

        for (uint256 i = 0; i < questionsBytes.length; i++) {
            found = true;
            for (uint256 j = 0; j < questionIdLength; j++) {
                if (questionsBytes[i + j] != questionIdBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                i += questionIdLength - 1;
            } else {
                result = abi.encodePacked(result, questionsBytes[i]);
            }
        }

        return string(result);
    }

    function getUserQuestions(string memory matchId, address userId) public view returns (string memory) {
        return userQuestions[matchId][userId];
    }
}
