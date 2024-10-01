//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

struct Bet {
    uint amount;
    uint candidate;
    uint timestamp;
    uint claimed;
}

struct Dispute {
    string candidate1;
    string candidate2;
    string image1;
    string image2;
    uint total1;
    uint total2;
    uint winner;
}

contract BetCandidate {

    Dispute public dispute;
    mapping(address => Bet) public allBets;

    address owner;
    uint fee = 1000; //10% (escala de 4 zeros)
    uint public netPrize;
    uint public prazoDaAposta;
    uint public commission;
    bool public commissionWithdrawn;

    constructor(){
        owner = msg.sender;
        dispute = Dispute({
            candidate1: "D. Trump",
            candidate2: "K. Harris",
            image1: "http://bit.ly/3zmSfiA",
            image2: "http://bit.ly/4gF4mYO",
            total1: 0,
            total2: 0,
            winner: 0
        });
        prazoDaAposta = block.timestamp + 60; // Define o prazo para 1 minuto.
    }

    modifier antesDoPrazo() {
        require(block.timestamp < prazoDaAposta, "O periodo de apostas ja terminou");
        _;
    }

    function bet(uint candidate) external payable antesDoPrazo {
        require(candidate == 1 || candidate == 2, "Candidato invalido");
        require(msg.value > 0, "Aposta invalida");
        require(dispute.winner == 0, "Disputa encerrada");

        Bet memory newBet;
        newBet.amount = msg.value;
        newBet.candidate = candidate;
        newBet.timestamp = block.timestamp;

        allBets[msg.sender] = newBet;

        if(candidate == 1)
            dispute.total1 += msg.value;
        else
            dispute.total2 += msg.value;    
    }

    function finish(uint winner) external {
        require(msg.sender == owner, "Conta invalida");
        require(winner == 1 || winner == 2, "Candidato invalido");
        require(dispute.winner == 0, "Disputa encerrada");

        dispute.winner = winner;

        uint grossPrize = dispute.total1 + dispute.total2;
        commission = (grossPrize * fee) / 1e4;
        netPrize = grossPrize - commission;
    }

    function claim() external {
        Bet memory userBet = allBets[msg.sender];
        require(dispute.winner > 0 && dispute.winner == userBet.candidate && userBet.claimed == 0, "Resgate invalido");

        uint winnerAmount = dispute.winner == 1 ? dispute.total1 : dispute.total2;
        uint ratio = (userBet.amount * 1e4) / winnerAmount;
        uint individualPrize = netPrize * ratio / 1e4;
        allBets[msg.sender].claimed = individualPrize;
        payable(msg.sender).transfer(individualPrize);
    }

    function sacarComissao() public {
        require(msg.sender == owner, "Somente o proprietario pode sacar a comissao");
        require(dispute.winner > 0, "A disputa ainda nao foi finalizada");
        require(!commissionWithdrawn, "A comissao ja foi sacada");
        commissionWithdrawn = true;
        payable(owner).transfer(commission);
    }
}
