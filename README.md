# SomLetrando 🧩🔊

**Projeto em FPGA para auxílio na criação de consciência fonológica de crianças no Transtorno do Espectro Autista (TEA).** 

Projeto desenvolvido para a disciplina **PCS3635 - Laboratório de Projeto de Sistemas Digitais I** da Escola Politécnica da USP.

---

## Colaboradores

  Altair Raphael Alcazar Perez
  
  Enzo Pimentel Lorenzon 
  
  Giovana Une Oyakawa

## Sobre o Projeto

  O aprendizado e a alfabetização de crianças com TEA demandam ferramentas que ofereçam previsibilidade, rotina e estímulos sensoriais adequados. O **SomLetrando** é um jogo interativo projetado para ensinar e praticar a associação de sons com letras para a formação de palavras de maneira lúdica. 

  Para mitigar as barreiras de aprendizagem motoras e sensoriais (sobrecarga de teclados convencionais), o projeto utiliza um painel tangível com botões de fliperama (Arcade) de texturas diversas. Todo o processamento lógico é feito de forma nativa em hardware programável, garantindo respostas em tempo real.
  
## Funcionalidades Principais

**Painel Tangível:** Substituição do teclado por botões Arcade físicos e texturizados, facilitando o uso por crianças com desafios de motricidade.

**Lógica Anti-Estereotipias (Debouncing):** O sistema em hardware controla o tempo entre cliques e exige um botão de "confirmação", evitando que toques múltiplos ou tremores registrem letras repetidas acidentalmente.

**Aleatoriedade de Desafios:** As palavras e a posição dos botões são geradas de forma aleatória pelo sistema, incentivando o aprendizado fonológico real no lugar da mera memorização de padrões.
**Modos de Dificuldade:** Permite adequar a progressão do jogo às competências da criança.

**Integração Audiovisual:** Comunicação via UART com um computador externo que emite o som da palavra escolhida.

## Tecnologias e Hardware

**Placa:** Intel FPGA DE0-CV 
**Linguagem de Descrição de Hardware (HDL):** Verilog 
**Software IDE:** Intel Quartus Prime & ModelSim 
**Componentes Externos:** Botões Arcade (PBS-29), LEDs, Chaves Gangorra 

