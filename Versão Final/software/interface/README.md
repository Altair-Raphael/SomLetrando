# SomLetrando - Interface

Esta pasta reúne apenas o conjunto mínimo para executar a interface gráfica principal do jogo em outro computador.

Como executar:

1. Instale as dependências com `pip install -r requirements.txt`.
2. Execute `python launcher.py` para abrir a interface principal.
3. Execute `python demo_launcher.py` para abrir a demo sem hardware.

Observação:

- A interface funciona mesmo sem o arquivo `configs/config_somletrando.json`, usando valores padrão.
- O arquivo de configuração foi incluído para preservar o comportamento visual original.
- A demo reutiliza os mesmos widgets visuais da interface principal.