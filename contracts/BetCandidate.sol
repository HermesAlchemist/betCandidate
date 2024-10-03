// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

struct Bet {
    uint amount;
    uint candidate;
    uint timestamp;
    bool claimed;
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

    address public immutable owner;
    uint public constant fee = 1000; // 10% (escala de 4 zeros)
    uint public netPrize;
    uint public commission;
    bool public commissionWithdrawn;

    uint public immutable bettingDeadline;
    uint public immutable finishDate;

    uint public totalBettors1;
    uint public totalBettors2;

    modifier onlyOwner() {
        require(msg.sender == owner, "Somente o proprietario pode chamar esta funcao");
        _;
    }

    constructor(uint _bettingDeadline, uint _finishDate){
        require(_finishDate > _bettingDeadline, "Data de finalizacao deve ser apos o prazo de apostas");
        owner = msg.sender;
        bettingDeadline = _bettingDeadline;
        finishDate = _finishDate;
        dispute = Dispute({
            candidate1: "D. Trump",
            candidate2: "K. Harris",
            image1: "http://bit.ly/3zmSfiA",
            image2: "http://bit.ly/4gF4mYO",
            total1: 0,
            total2: 0,
            winner: 0
        });
    }

    function bet(uint candidate) external payable {
        require(block.timestamp <= bettingDeadline, "Periodo de apostas encerrado");
        require(candidate == 1 || candidate == 2, "Candidato invalido");
        require(msg.value > 0, "Aposta invalida");
        require(dispute.winner == 0, "Disputa encerrada");
        require(allBets[msg.sender].amount == 0, "Voce ja fez uma aposta");

        Bet memory newBet;
        newBet.amount = msg.value;
        newBet.candidate = candidate;
        newBet.timestamp = block.timestamp;
        newBet.claimed = false;

        allBets[msg.sender] = newBet;

        if(candidate == 1) {
            dispute.total1 += msg.value;
            totalBettors1 += 1;
        } else {
            dispute.total2 += msg.value;
            totalBettors2 += 1;
        }
    }

    function finish(uint winner) external onlyOwner {
        require(block.timestamp >= finishDate, "Nao e possivel finalizar antes da data definida");
        require(winner == 1 || winner == 2, "Candidato invalido");
        require(dispute.winner == 0, "Disputa encerrada");

        dispute.winner = winner;

        uint grossPrize = dispute.total1 + dispute.total2;
        commission = (grossPrize * fee) / 1e4;
        netPrize = grossPrize - commission;
    }

    function withdrawCommission() external onlyOwner {
        require(dispute.winner != 0, "Disputa ainda nao finalizada");
        require(!commissionWithdrawn, "Comissao ja sacada");
        commissionWithdrawn = true;
        payable(owner).transfer(commission);
    }

    function claim() external {
        Bet storage userBet = allBets[msg.sender];
        require(dispute.winner > 0 && dispute.winner == userBet.candidate && !userBet.claimed, "Reivindicacao invalida");

        uint winnerAmount = dispute.winner == 1 ? dispute.total1 : dispute.total2;
        uint ratio = (userBet.amount * 1e4) / winnerAmount;
        uint individualPrize = (netPrize * ratio) / 1e4;
        userBet.claimed = true;
        payable(msg.sender).transfer(individualPrize);
    }

    function updateCandidateInfo(
        string calldata _candidate1,
        string calldata _candidate2,
        string calldata _image1,
        string calldata _image2
    ) external onlyOwner {
        dispute.candidate1 = _candidate1;
        dispute.candidate2 = _candidate2;
        dispute.image1 = _image1;
        dispute.image2 = _image2;
    }
}
