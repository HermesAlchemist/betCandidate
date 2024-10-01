#BetCandidate Smart Contract

This repository contains the BetCandidate smart contract, which allows users to place bets on candidates in a dispute. The contract facilitates betting, determines a winner, and allows users to claim their rewards based on their contributions. The contract also enables the owner to collect a commission from the total prize pool after the dispute is finalized.

#🔑 Features

Betting on Candidates:

Users can bet on one of two candidates by specifying their candidate and the amount they wish to bet.
Bets are recorded in the allBets mapping, which stores details like bet amount, candidate choice, timestamp, and whether the reward has been claimed.
Dispute Management:

The contract supports two candidates in a dispute, with their respective names and images.
The owner can finalize the dispute by declaring a winner, after which the prize distribution process starts.
Prize Pool and Commission:

A commission of 10% is collected from the total prize pool by the contract owner.
The remaining prize pool is distributed among users who bet on the winning candidate based on their proportional contribution.
Claiming Rewards:

After the dispute ends, users who bet on the winning candidate can claim their prize, which is calculated based on the total amount bet and the user’s contribution.
Commission Withdrawal:

The contract owner can withdraw the commission only after the dispute has ended and the winner is declared.

#📝Contract Details

Owner: The contract deployer is assigned as the owner and is responsible for declaring the winner and withdrawing the commission.
Bet Struct:
Bet holds individual betting information: the amount bet, candidate number, timestamp, and claimed status.
Dispute Struct:
Dispute contains the names and images of the two candidates, the total amount bet on each candidate, and the final winner.
Fee and Prize Calculation:
The contract applies a 10% fee (represented as fee = 1000 with 4 decimal scaling) to the total prize pool before distributing the rewards.

#🚀Functions

bet(uint candidate)
Allows users to place their bet on a candidate (either 1 or 2). The bet is only accepted if it meets the following criteria:

The bet is placed before the deadline (prazoDaAposta).
The candidate is valid (either 1 or 2).
The dispute has not yet been finalized.
finish(uint winner)
Allows the contract owner to finalize the dispute and declare a winner. This function calculates the gross prize pool, deducts the commission, and sets the net prize for distribution.

claim()
Allows users who placed a bet on the winning candidate to claim their reward. The reward is calculated based on the total amount bet on the winning candidate and the user’s contribution.

sacarComissao()
Allows the contract owner to withdraw the commission from the total prize pool. The commission can only be withdrawn once, and only after the dispute is finalized.

#🔧Requirements

Solidity version: ^0.8.26
The contract is licensed under the MIT License.

#📦Deployment
Deploy the contract with the default constructor. The dispute is initialized with pre-set candidates.
Users can place bets until the betting deadline (prazoDaAposta).
The owner can declare the winner after the deadline.
Users can claim their rewards, and the owner can withdraw the commission.

#📜License
This project is licensed under the MIT License. See the LICENSE file for details.

Feel free to reach out if you have any questions or need further clarification!
