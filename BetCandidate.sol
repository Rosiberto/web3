//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

struct Disputa{
    string candidato1;
    string canditato2;
    string foto1;
    string foto2;
    uint total1;
    uint total2;
    uint vencedor;
    
}

struct Aposta { 
    uint quantia;
    uint candidato;
    uint timestamp;
    uint sacado;
}

contract BetCandidate{

    Disputa public disputa;

    mapping(address => Aposta) public allApostas;

    //endereço da carteira na blockchain 
    address donoCarteira;
    //uint significa que não aceita numeros negativos
    uint taxaComissao = 1000;// = a 100% divide por 100
    uint public premioLiquido;

    constructor(){
        // armazena quem disparou a mensagem ou seja, quem iniciou este contrato
        donoCarteira = msg.sender;
        disputa = Disputa( {
            candidato1: "Trump",
            canditato2: "kamala",
            foto1: "https://www.google.com.br/imgres?q=trump&imgurl=https%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2F5%2F56%2FDonald_Trump_official_portrait.jpg&imgrefurl=https%3A%2F%2Fpt.wikipedia.org%2Fwiki%2FDonald_Trump&docid=YIczOAYF8oOmOM&tbnid=2TPxeYTLyNplWM&vet=12ahUKEwjnosD77-qIAxW1ppUCHVpyK9AQM3oECBIQAA..i&w=2250&h=2850&hcb=2&ved=2ahUKEwjnosD77-qIAxW1ppUCHVpyK9AQM3oECBIQAA",
            foto2: "https://www.google.com.br/imgres?q=kamala&imgurl=https%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2F4%2F41%2FKamala_Harris_Vice_Presidential_Portrait.jpg&imgrefurl=https%3A%2F%2Fpt.wikipedia.org%2Fwiki%2FKamala_Harris&docid=y9LZ6Jgq4iVpNM&tbnid=i06D9QiMIWkgXM&vet=12ahUKEwi0w7WG8OqIAxWmqJUCHfB4J8kQM3oECB0QAA..i&w=2400&h=3000&hcb=2&ved=2ahUKEwi0w7WG8OqIAxWmqJUCHfB4J8kQM3oECB0QAA",
            total1:0,
            total2:0,
            vencedor: 0
        } );
    }

    function apostar(uint candidato) external payable {
        require(candidato == 1 || candidato == 2, "Invalid candidate");
        require(msg.value > 0, "Disputa Invalida");
        require(disputa.vencedor == 0, "Disputa fechada");
    
        Aposta memory novaAposta;
        novaAposta.quantia = msg.value;
        novaAposta.candidato = candidato;
        novaAposta.timestamp = block.timestamp;

        allApostas[msg.sender] = novaAposta;

        if(candidato == 1) {
            disputa.total1 += msg.value;
        }else {
            disputa.total2 += msg.value;
        }
    }
    
    function fecharAposta(uint vencedor) external {
        require(msg.sender == donoCarteira, "Conta invalida");
        require(vencedor == 1 || vencedor == 2, "Candidato invalido");
        require(disputa.vencedor == 0, "Disputa fechada");
        
        disputa.vencedor = vencedor;

        uint premioBruto = disputa.total1 + disputa.total2;
        uint comissaoCasa = (premioBruto * taxaComissao) / 1e4; //1e4 é 10000 na escala cientifica

        premioLiquido = premioBruto - comissaoCasa;

        payable(donoCarteira).transfer(comissaoCasa);
    }

    function pagarAposta() external {
        Aposta memory apostador = allApostas[msg.sender];
        require(disputa.vencedor > 0 && disputa.vencedor == apostador.candidato && apostador.sacado == 0, "Saque invalido");

        uint valorSacado = disputa.vencedor == 1 ? disputa.total1 : disputa.total2;
        uint taxa = (apostador.quantia * 1e4) / valorSacado;
        uint valorApagar = premioLiquido * taxa / 1e4;
        allApostas[msg.sender].sacado = valorApagar;
        
        payable(msg.sender).transfer(valorApagar);    
    }    
}