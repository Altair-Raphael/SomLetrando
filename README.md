# SomLetrando 🧩🔊

[cite_start]**Projeto em FPGA para auxílio na criação de consciência fonológica de crianças no Transtorno do Espectro Autista (TEA).** 

[cite_start]Projeto desenvolvido para a disciplina **PCS3635 - Laboratório de Projeto de Sistemas Digitais I** da Escola Politécnica da USP (Poli-USP)[cite: 4, 5].

---

#Colaboradores

  Altair Raphael Alcazar Perez
  Enzo Pimentel Lorenzon 
  Giovana Une Oyakawa

## 📖 Sobre o Projeto

[cite_start]O aprendizado e a alfabetização de crianças com TEA demandam ferramentas que ofereçam previsibilidade, rotina e estímulos sensoriais adequados[cite: 32]. [cite_start]O **SomLetrando** é um jogo interativo projetado para ensinar e praticar a associação de sons com letras para a formação de palavras de maneira lúdica[cite: 23]. 

[cite_start]Para mitigar as barreiras de aprendizagem motoras e sensoriais (sobrecarga de teclados convencionais), o projeto utiliza um painel tangível com botões de fliperama (Arcade) de texturas diversas[cite: 53, 73]. [cite_start]Todo o processamento lógico é feito de forma nativa em hardware programável, garantindo respostas em tempo real[cite: 55].

## Funcionalidades Principais

* [cite_start]**Painel Tangível:** Substituição do teclado por botões Arcade físicos e texturizados, facilitando o uso por crianças com desafios de motricidade[cite: 53, 73].
* [cite_start]**Lógica Anti-Estereotipias (Debouncing):** O sistema em hardware controla o tempo entre cliques e exige um botão de "confirmação", evitando que toques múltiplos ou tremores registrem letras repetidas acidentalmente[cite: 55, 237].
* [cite_start]**Aleatoriedade de Desafios:** As palavras e a posição dos botões são geradas de forma aleatória pelo sistema, incentivando o aprendizado fonológico real no lugar da mera memorização de padrões[cite: 288, 300].
* [cite_start]**Modos de Dificuldade:** Permite adequar a progressão do jogo às competências da criança[cite: 256, 264].
* [cite_start]**Integração Audiovisual:** Comunicação via UART com um computador externo que emite o som da palavra escolhida[cite: 56, 138].

## 🛠️ Tecnologias e Hardware

* [cite_start]**Placa:** Intel FPGA DE0-CV [cite: 55]
* [cite_start]**Linguagem de Descrição de Hardware (HDL):** Verilog [cite: 325]
* [cite_start]**Software IDE:** Intel Quartus Prime & ModelSim [cite: 325, 327]
* [cite_start]**Componentes Externos:** Botões Arcade (PBS-29), LEDs, Chaves Gangorra [cite: 64, 65]

