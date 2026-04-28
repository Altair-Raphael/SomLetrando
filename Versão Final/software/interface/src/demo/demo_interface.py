#!/usr/bin/env python3
"""
================================================================================
 Arquivo   : demo_interface.py
 Projeto   : SomLetrando
================================================================================
 Descrição : Demo/Preview da interface gráfica SEM hardware FPGA
             Simula envio de palavras e letras para testar visualmente
             Permite testar cores, tamanhos e customizações
================================================================================
 Como usar:
     python -m src.demo.demo_interface
     ou
     cd src/demo && python demo_interface.py
     
     Botões disponíveis:
     - "Enviar Palavra": Simula FPGA enviando uma palavra
     - "Próxima Letra": Simula acerto e envia próxima letra
     - "Erro": Simula erro na seleção
     - "Reset": Reseta o jogo
================================================================================
"""

import sys
import threading
import time

from pathlib import Path
from typing import Optional

from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, 
    QLabel, QPushButton, QComboBox, QMessageBox, QTabWidget, QTextEdit, QSpinBox
)
from PyQt5.QtCore import Qt, pyqtSignal, pyqtSlot, QTimer
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QStackedLayout
from PyQt5.QtGui import QMovie
from PyQt5.QtGui import QPixmap
from PyQt5.QtWidgets import QGraphicsOpacityEffect
from pathlib import Path

# Garante que a raiz do projeto está no sys.path quando executado como script.
PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

# Importa gestor de configurações
try:
    from ..config import config
except ImportError:
    try:
        from src.config import config
    except ImportError:
        print("[WARNING] Gestor de configurações não encontrado. Usando valores padrão.")
        config = None

# Importa classe DisplayPalavra da interface real
try:
    from ..gui.display_palavra import DisplayPalavra
except ImportError:
    try:
        from src.gui.display_palavra import DisplayPalavra
    except ImportError:
        print("[ERROR] Interface gráfica não encontrada!")
        sys.exit(1)


# ============================================================================== 
# Helper para cores e tamanhos
# ============================================================================== 

def obtem_cor(chave: str, padrao: str = "#000000") -> str:
    """Obtém cor da configuração ou usa padrão"""
    if not config:
        return padrao
    
    try:
        return config.get(f"cores.{chave}", padrao)
    except:
        return padrao


def obtem_tamanho_fonte(chave: str, padrao: int = 12) -> int:
    """Obtém tamanho de fonte da configuração ou usa padrão"""
    if not config:
        return padrao
    
    try:
        return config.get(f"fontes.{chave}", padrao)
    except:
        return padrao


# ============================================================================== 
# SIMULADOR DE FPGA
# ============================================================================== 

class SimuladorFPGA:
    """Simula comportamento da FPGA enviando palavras e letras"""
    
    # Palavras disponíveis (mesmo da memória FPGA)
    PALAVRAS = ["LAB", "SIM", "LAR", "ASA"] # Adicao de novas palavras
    # Niveis de dificuldade disponíveis
    NIVEIS = ["0: Iniciante" , "1: Veterano"]
    
    def __init__(self):
        self.palavra_atual = ""
        self.indice_letra = 0
        self.palavra_index = 0
        self.callback_palavra = None
        self.callback_letra = None
    
    def set_callbacks(self, callback_palavra, callback_letra):
        """Registra callbacks para simular eventos"""
        self.callback_palavra = callback_palavra
        self.callback_letra = callback_letra
    
    def envia_palavra(self, index: Optional[int] = None):
        """Simula FPGA enviando uma palavra"""
        if index is not None:
            self.palavra_index = index % len(self.PALAVRAS)
        
        self.palavra_atual = self.PALAVRAS[self.palavra_index]
        self.indice_letra = 0
        
        print(f"[SIMULADOR] Enviando palavra: {self.palavra_atual}")
        if self.callback_palavra:
            self.callback_palavra(self.palavra_atual)
    
    def envia_proxima_letra(self):
        """Simula FPGA enviando a próxima letra correta"""
        if not self.palavra_atual:
            print("[SIMULADOR] Nenhuma palavra em progresso!")
            return False
        
        if self.indice_letra >= len(self.palavra_atual):
            # Fim da palavra
            print("[SIMULADOR] Palavra completa!")
            return False
        
        letra = self.palavra_atual[self.indice_letra]
        print(f"[SIMULADOR] Enviando letra: {letra} ({self.indice_letra + 1}/{len(self.palavra_atual)})")
        
        if self.callback_letra:
            self.callback_letra(letra)
        
        self.indice_letra += 1
        return True
    
    def proxima_palavra(self):
        """Avança para próxima palavra"""
        self.palavra_index = (self.palavra_index + 1) % len(self.PALAVRAS)
    
    def palavra_anterior(self):
        """Volta para palavra anterior"""
        self.palavra_index = (self.palavra_index - 1) % len(self.PALAVRAS)


# ============================================================================== 
# INTERFACE DE DEMO COM CONTROLES
# ============================================================================== 

class DemoSomLetrando(QMainWindow):
    """Interface de demo do SomLetrando com controles para simular FPGA"""
    
    # Sinais (mesmo padrão que a interface real)
    palavra_recebida = pyqtSignal(str)
    letra_recebida = pyqtSignal(str)
    
    def __init__(self):
        super().__init__()
        self.modo_jogo = None
        self.erros = 0
        self.max_erros = 3
        
        # Título e dimensões
        titulo = "SomLetrando - DEMO (Simulação)"
        if config:
            titulo = config.get("interface.titulo", titulo) + " [DEMO]"
        
        self.setWindowTitle(titulo)
        self.setGeometry(100, 100, 1400, 800)
        
        # Estado do jogo
        self.palavra_atual = ""
        self.indice_letra = 0
        self.contador_erros = 0
        self.modo_manual = True  # True = manual, False = automático
        
        # Simulador FPGA
        self.simulador = SimuladorFPGA()
        self.simulador.set_callbacks(self.processa_palavra, self.processa_letra)
        
        # UI
        self.inicializa_ui()
        
        # Conecta sinais
        self.palavra_recebida.connect(self.processa_palavra)
        self.letra_recebida.connect(self.processa_letra)
    
    def inicializa_ui(self):
        widget_principal = QWidget()
        self.setCentralWidget(widget_principal)
        layout_principal = QVBoxLayout(widget_principal)

        self.tabs = QTabWidget()
        layout_principal.addWidget(self.tabs)

        # cria telas
        self.tela_inicio = self.cria_tela_inicial()
        self.tela_jogo = self.cria_aba_jogo()
        self.tela_vitoria = self.cria_tela_vitoria()
        self.tela_derrota = self.cria_tela_derrota()

        self.tabs.addTab(self.tela_inicio, "🏠 Início")
        self.tabs.addTab(self.tela_jogo, "🎮 Jogo")
        self.tabs.addTab(self.tela_vitoria, "🏆 Vitória")
        self.tabs.addTab(self.tela_derrota, "😞 Derrota")

        # tela inicial
        self.tabs.setCurrentWidget(self.tela_inicio)

    def cria_tela_inicial(self):
        widget = QWidget()
        layout = QVBoxLayout(widget)
        label_logo = QLabel()
        caminho_logo = Path(__file__).resolve().parents[2] / "src/assets/Logov1.png"
        pixmap = QPixmap(str(caminho_logo))

        label_logo.setPixmap(pixmap.scaled(800, 850, Qt.KeepAspectRatio, Qt.SmoothTransformation))
        label_logo.setAlignment(Qt.AlignCenter)

        self.label_status_inicio = QLabel("Aguardando início de partida...")
        self.label_status_inicio.setAlignment(Qt.AlignCenter)
        self.label_status_inicio.setStyleSheet("font-size: 25px;")

        # Botao criado para o teste sem hardware
        botao_demo = QPushButton("▶️  Iniciar Demo")
        botao_demo.setStyleSheet("""
        QPushButton {
            background-color: #4CAF50;
            color: white;
            font-size: 20px;
            padding: 12px;
            border-radius: 8px;
        }
        QPushButton:hover {
            background-color: #45a049;
        }
        QPushButton:pressed {
            background-color: #388E3C;
        }
        """)
        botao_demo.clicked.connect(self.iniciar_demo_sem_fpga)

        botao_como_jogar = QPushButton("Como Jogar ?")
        botao_como_jogar.setStyleSheet("""
            QPushButton {
                background-color: transparent;
                color: #555;
                font-size: 15px;
                padding: 10px;
                border: 2px solid #ccc;
                border-radius: 8px;
            }
            QPushButton:hover {
                background-color: #f0f0f0;
                border: 2px solid #999;
            }
        """)
        botao_como_jogar.clicked.connect(self.mostra_como_jogar)

        layout.addStretch()
        layout.addWidget(label_logo)
        layout.addWidget(self.label_status_inicio)
        layout.addSpacing(30)
        layout_botoes = QVBoxLayout()
        layout_botoes.setSpacing(15)
        botao_demo.setFixedWidth(250)
        botao_como_jogar.setFixedWidth(250)
        layout_botoes.addWidget(botao_demo)
        layout_botoes.addWidget(botao_como_jogar)
        layout_botoes.setAlignment(Qt.AlignCenter)
        layout.addLayout(layout_botoes)
        layout.addStretch()

        return widget
    
    def iniciar_demo_sem_fpga(self):
        self.tabs.setCurrentWidget(self.tela_jogo)
    
    def cria_aba_jogo(self):
        """Cria aba principal com o jogo"""
        widget_jogo = QWidget()
        layout_jogo = QVBoxLayout(widget_jogo)
        layout_jogo.setContentsMargins(20, 20, 20, 20)
        layout_jogo.setSpacing(20)
        
        # Status
        layout_status = QHBoxLayout()
        self.label_status = QLabel("Status: Aguardando você enviar uma palavra")
        fonte_status = QFont()
        fonte_status.setPointSize(14)
        fonte_status.setBold(True)
        self.label_status.setFont(fonte_status)
        layout_status.addWidget(self.label_status)
        
        layout_status.addStretch()
        
        self.label_erros = QLabel("Erros: 0")
        fonte_erros = QFont()
        fonte_erros.setPointSize(14)
        fonte_erros.setBold(True)
        self.label_erros.setFont(fonte_erros)
        layout_status.addWidget(self.label_erros)

        self.label_vidas = QLabel("❤️❤️❤️")
        fonte_vidas = QFont("Segoe UI Emoji", 14)  # fonte que suporta emoji
        self.label_vidas.setFont(fonte_vidas)
        fonte_vidas.setPointSize(20)
        self.label_vidas.setFont(fonte_vidas)
        self.label_vidas.setAlignment(Qt.AlignCenter)

        layout_jogo.addWidget(self.label_vidas)
        
        layout_jogo.addLayout(layout_status)
        
        # Display da palavra
        self.display_palavra = DisplayPalavra()
        layout_jogo.addWidget(self.display_palavra)
        
        # Mensagem grande
        self.label_mensagem = QLabel("")
        fonte_msg = QFont()
        fonte_msg.setPointSize(28)
        fonte_msg.setBold(True)
        self.label_mensagem.setFont(fonte_msg)
        self.label_mensagem.setAlignment(Qt.AlignCenter)
        self.label_mensagem.setStyleSheet("color: #333333;")
        layout_jogo.addWidget(self.label_mensagem)
        
        # Instrução
        self.label_instrucao = QLabel(
            "👉 Use a aba 'Controles de Demo' para simular:\n"
            "   1. Enviar palavra\n"
            "   2. Confirmar letras (acertos)\n"
            "   3. Simular erros\n"
            "   4. Reset do jogo"
        )
        fonte_instr = QFont()
        fonte_instr.setPointSize(12)
        self.label_instrucao.setFont(fonte_instr)
        self.label_instrucao.setStyleSheet("background-color: #E8F4F8; padding: 15px; border-radius: 8px;")
        layout_jogo.addWidget(self.label_instrucao)

        botao_controles = QPushButton("⚙️ Controles Demo")
        botao_controles.clicked.connect(self.cria_aba_controles)
        botao_controles.setStyleSheet("""
            QPushButton {
                background-color: #555;
                color: white;
                padding: 8px;
                border-radius: 6px;
            }
            QPushButton:hover {
                background-color: #777;
            }
        """)
        layout_jogo.addWidget(botao_controles)
        
        return widget_jogo
    
    def atualiza_vidas(self):
        vidas_restantes = self.max_erros - self.contador_erros

        coracoes = "❤️" * vidas_restantes
        vazios = "💔" * self.contador_erros

        self.label_vidas.setText(coracoes + vazios)

    def mostra_como_jogar(self):
        QMessageBox.information(
            self,
            "Como Jogar",
            "<b>🧩 COMO JOGAR 🧩</b><br>"
            "Nesse jogo você pode escolher entre dois modos de jogo:<br><br>"
            
            "1) Modo Iniciante<br>"
            "- Ao acionar o botão de repetir, o alto falante reproduzirá a <b>letra</b> a ser acertada;<br>"
            "- Você tem direito a <b>3 erros por tentativa</b> de acertar uma letra!<br><br>"
            
            "2) Modo Veterano:<br>"
            "- O botão de repetir reproduz no alto falante a <b>palavra</b> inteira a ser acertada independente do momento do jogo;<br>"
            "- Você tem direito a <b>3 erros</b>, mas eles são cumulativos durante toda a partida!<br><br>"
            
            "<b>OBJETIVO:</b><br>"
            "Acerte todas as letras da palavra e se divirta!<br>"
            "Boa sorte!!! 🍀"
    )
    
    def cria_aba_controles(self):
        """Cria aba com controles para simular FPGA"""
        widget_controles = QWidget()
        layout_controles = QVBoxLayout(widget_controles)
        layout_controles.setContentsMargins(20, 20, 20, 20)
        layout_controles.setSpacing(15)

        # Modos de jogo
        label_secao4 = QLabel("MODOS DE JOGO")
        fonte_secao = QFont()
        fonte_secao.setPointSize(12)
        fonte_secao.setBold(True)
        label_secao4.setFont(fonte_secao)
        layout_controles.addWidget(label_secao4)
        
        layout_nivel = QHBoxLayout()
        
        label_nivel = QLabel("Dificuldade escolhida: ")
        self.combo_nivel = QComboBox()
        self.combo_nivel.addItems(self.simulador.NIVEIS)
        layout_nivel.addWidget(label_nivel)
        layout_nivel.addWidget(self.combo_nivel)
        
        layout_nivel.addStretch()
        
        botao_enviar_nivel = QPushButton("✅ DEFINIR MODO")
        botao_enviar_nivel.setStyleSheet(
            "background-color: #4CAF50; color: white; font-size: 14px; "
            "font-weight: bold; padding: 10px; border-radius: 5px;"
        )
        botao_enviar_nivel.clicked.connect(self.envia_nivel)
        layout_nivel.addWidget(botao_enviar_nivel)
        
        layout_controles.addLayout(layout_nivel)

        # Separador
        separator1 = QLabel("─" * 80)
        layout_controles.addWidget(separator1)
        
        # === Seção: Seleção de Palavra ===
        label_secao1 = QLabel("📝 SELECIONAR PALAVRA")
        fonte_secao = QFont()
        fonte_secao.setPointSize(12)
        fonte_secao.setBold(True)
        label_secao1.setFont(fonte_secao)
        layout_controles.addWidget(label_secao1)
        
        layout_palavra = QHBoxLayout()
        
        label_palavra = QLabel("Palavra:")
        self.combo_palavra = QComboBox()
        self.combo_palavra.addItems(self.simulador.PALAVRAS)
        layout_palavra.addWidget(label_palavra)
        layout_palavra.addWidget(self.combo_palavra)
        
        botao_anterior = QPushButton("← Anterior")
        botao_anterior.clicked.connect(self.anterior_palavra)
        layout_palavra.addWidget(botao_anterior)
        
        botao_proxima = QPushButton("Próxima →")
        botao_proxima.clicked.connect(self.proxima_palavra)
        layout_palavra.addWidget(botao_proxima)
        
        layout_palavra.addStretch()
        
        botao_enviar_palavra = QPushButton("✅ ENVIAR PALAVRA")
        botao_enviar_palavra.setStyleSheet(
            "background-color: #4CAF50; color: white; font-size: 14px; "
            "font-weight: bold; padding: 10px; border-radius: 5px;"
        )
        botao_enviar_palavra.clicked.connect(self.envia_palavra)
        layout_palavra.addWidget(botao_enviar_palavra)
        
        layout_controles.addLayout(layout_palavra)
        
        # Separador
        separator2 = QLabel("─" * 80)
        layout_controles.addWidget(separator2)
       
        # === Seção: Letras ===
        label_secao2 = QLabel("📮 SIMULAR LETRAS")
        label_secao2.setFont(fonte_secao)
        layout_controles.addWidget(label_secao2)
        
        layout_letras = QHBoxLayout()
        
        botao_proxima_letra = QPushButton("✅ CONFIRMAR LETRA (Acerto)")
        botao_proxima_letra.setStyleSheet(
            "background-color: #2196F3; color: white; font-size: 12px; "
            "font-weight: bold; padding: 8px; border-radius: 5px;"
        )
        botao_proxima_letra.clicked.connect(self.confirma_letra)
        layout_letras.addWidget(botao_proxima_letra)
        
        botao_erro = QPushButton("❌ ERRO")
        botao_erro.setStyleSheet(
            "background-color: #9D00FF; color: white; font-size: 12px; "
            "font-weight: bold; padding: 8px; border-radius: 5px;"
        )
        botao_erro.clicked.connect(self.simula_erro)
        layout_letras.addWidget(botao_erro)
        
        layout_controles.addLayout(layout_letras)

        # Separador
        separator3 = QLabel("─" * 80)
        layout_controles.addWidget(separator3)
        
        # === Seção: Modo Automático ===
        label_secao3 = QLabel("⚙️  MODO AUTOMÁTICO (Demonstração)")
        label_secao3.setFont(fonte_secao)
        layout_controles.addWidget(label_secao3)
        
        layout_auto = QHBoxLayout()
        
        label_intervalo = QLabel("Intervalo entre letras (ms):")
        self.spin_intervalo = QSpinBox()
        self.spin_intervalo.setValue(1500)
        self.spin_intervalo.setRange(500, 5000)
        layout_auto.addWidget(label_intervalo)
        layout_auto.addWidget(self.spin_intervalo)
        
        layout_auto.addStretch()
        
        self.botao_auto = QPushButton("▶️  INICIAR DEMO AUTOMÁTICA")
        self.botao_auto.setStyleSheet(
            "background-color: #FF9800; color: white; font-size: 12px; "
            "font-weight: bold; padding: 8px; border-radius: 5px;"
        )
        self.botao_auto.clicked.connect(self.inicia_demo_automatica)
        layout_auto.addWidget(self.botao_auto)
        
        layout_controles.addLayout(layout_auto)
        
        # Separador
        separator4 = QLabel("─" * 80)
        layout_controles.addWidget(separator4)
        
        # === Reset ===
        botao_reset = QPushButton("🔄 RESET JOGO")
        botao_reset.setStyleSheet(
            "background-color: #9C27B0; color: white; font-size: 14px; "
            "font-weight: bold; padding: 10px; border-radius: 5px;"
        )
        botao_reset.clicked.connect(self.reseta_jogo)
        layout_controles.addWidget(botao_reset)
        
        layout_controles.addStretch()
        
        self.tabs.addTab(widget_controles, "🎮 Controles de Demo")

    def envia_nivel(self):
        self.modo_jogo = self.combo_nivel.currentText()
        self.aplica_estilo_modo()

        if self.modo_jogo == "0: Iniciante":
            self.max_erros = 3
            QMessageBox.information(
            self,
            "Modo selecionado",
            f"Modo {self.modo_jogo} ativado!\nMáximo de erros: {self.max_erros} por letra"
            )
        elif self.modo_jogo == "1: Veterano":
            self.max_erros = 3  # depois você pode mudar se quiser
            QMessageBox.information(
            self,
            "Modo selecionado",
            f"Modo {self.modo_jogo} ativado!\nMáximo de erros: {self.max_erros} na jogada toda!"
            )
        
    def cria_aba_info(self):
        """Cria aba com informações e teste de cores"""
        widget_info = QWidget()
        layout_info = QVBoxLayout(widget_info)
        layout_info.setContentsMargins(20, 20, 20, 20)
        layout_info.setSpacing(20)
        
        # Info
        label_info = QLabel(
            "ℹ️  INFORMAÇÕES DA DEMO\n\n"
            "Esta é uma versão de preview/demo da interface SomLetrando.\n"
            "Permite visualizar e testar a interface gráfica SEM necessidade\n"
            "de placa FPGA.\n\n"
            "✅ Recursos disponíveis:\n"
            "  • Seleção de palavras\n"
            "  • Simulação de envio de letras\n"
            "  • Teste de cores customizadas\n"
            "  • Modo automático de demonstração\n"
            "  • Visualização de todos os estados do jogo\n\n"
            "🎨 Cores carregadas de: config_somletrando.json\n"
            "📏 Tamanhos carregados de: config_somletrando.json\n\n"
            "Modifique config_somletrando.json e reinicie para ver mudanças!"
        )
        fonte_info = QFont()
        fonte_info.setPointSize(11)
        label_info.setFont(fonte_info)
        label_info.setStyleSheet("background-color: #F0F8FF; padding: 15px; border-radius: 8px;")
        layout_info.addWidget(label_info)
        
        # === Teste de Cores ===
        label_cores = QLabel("🎨 TESTE DE CORES")
        fonte_secao = QFont()
        fonte_secao.setPointSize(12)
        fonte_secao.setBold(True)
        label_cores.setFont(fonte_secao)
        layout_info.addWidget(label_cores)
        
        layout_cores = QHBoxLayout()
        
        cores_teste = [
            ("N. Selecionada", "letra_nao_selecionada", "#000000"),
            ("Atual", "letra_atual", "#FFD700"),
            ("Acertada", "letra_acertada", "#00AA00"),
            ("Erro", "letra_erro", "#CC0000"),
            ("Vitória", "texto_vitoria", "#006600"),
            ("Derrota", "texto_derrota", "#660000"),
        ]
        
        for nome, chave, padrao in cores_teste:
            cor = obtem_cor(chave, padrao)
            label_cor = QLabel(nome)
            label_cor.setStyleSheet(f"background-color: {cor}; color: white; padding: 8px; border-radius: 4px; font-weight: bold;")
            layout_cores.addWidget(label_cor)
        
        layout_info.addLayout(layout_cores)
        
        # Status
        layout_info.addStretch()
        
        label_status_demo = QLabel("🔧 Status: Pronto para demo")
        label_status_demo.setStyleSheet("background-color: #E8F5E9; padding: 10px; border-radius: 4px; font-weight: bold;")
        layout_info.addWidget(label_status_demo)
        
        self.tabs.addTab(widget_info, "ℹ️  Info")
    
    def cria_tela_derrota(self):
        widget = QWidget()
        layout_texto = QVBoxLayout(widget)

        layout_texto.addStretch()

        self.label_derrota = QLabel("😞 Perdeu... 😞")
        self.label_derrota.setAlignment(Qt.AlignCenter)
        self.label_derrota.setStyleSheet("""
            font-size: 50px;
            color: white;
            font-weight: bold;
            background-color: rgba(0, 0, 0, 120);
            padding: 10px;
            border-radius: 10px;
        """)

        self.label_nao_desanimar = QLabel ("Não foi dessa vez, mas não desanime! Tente novamente!!")
        self.label_nao_desanimar.setAlignment(Qt.AlignCenter)

        botao_reset = QPushButton("🔄 Jogar novamente")
        botao_reset.clicked.connect(self.volta_inicio)
        botao_reset.setFixedWidth(200)
        botao_reset.setStyleSheet("""
            font-size: 18px;
            padding: 10px;
            background-color: rgba(0,0,0,150);
            color: white;
            border-radius: 8px;
        """)

        layout_texto.addWidget(self.label_derrota)
        layout_texto.addSpacing(10)
        layout_texto.addWidget(self.label_nao_desanimar)
        layout_texto.addSpacing(20)
        layout_texto.addWidget(botao_reset, alignment=Qt.AlignCenter)
        layout_texto.addStretch()

        return widget

    def cria_tela_vitoria(self):
        widget = QWidget()

        layout_stack = QStackedLayout(widget)

        # ===== 🎬 GIF FUNDO =====
        self.label_gif = QLabel()
        self.label_gif.setAlignment(Qt.AlignCenter)

        caminho_gif = Path(__file__).resolve().parents[2] / "src/assets/confete.gif"
        self.movie = QMovie(str(caminho_gif))

        self.label_gif.setMovie(self.movie)
        self.movie.start()

        efeito = QGraphicsOpacityEffect()
        efeito.setOpacity(0.4)
        self.label_gif.setGraphicsEffect(efeito)

        # faz o GIF preencher tudo
        self.label_gif.setScaledContents(True)

        # ===== 📝 TEXTO POR CIMA =====
        container_texto = QWidget()
        container_texto.setAttribute(Qt.WA_TransparentForMouseEvents, False)
        container_texto.setStyleSheet("background: transparent;")
        layout_texto = QVBoxLayout(container_texto)

        layout_texto.addStretch()

        self.label_vitoria = QLabel("🎉 PARABÉNS! 🎉")
        self.label_vitoria.setAlignment(Qt.AlignCenter)
        self.label_vitoria.setStyleSheet("""
            font-size: 50px;
            color: white;
            font-weight: bold;
            background-color: rgba(0, 0, 0, 120);
            padding: 10px;
            border-radius: 10px;
        """)

        botao_reset = QPushButton("Jogar novamente")
        botao_reset.clicked.connect(self.volta_inicio)

        botao_reset.setStyleSheet("""
            font-size: 18px;
            padding: 10px;
            background-color: rgba(0,0,0,150);
            color: white;
            border-radius: 8px;
        """)

        layout_texto.addWidget(self.label_vitoria)
        layout_texto.addSpacing(20)
        layout_texto.addWidget(botao_reset, alignment=Qt.AlignCenter)

        layout_texto.addStretch()

        self.label_gif.setAttribute(Qt.WA_TransparentForMouseEvents, True)
        container_texto.raise_()

        # ===== EMPILHA =====
        layout_stack.setStackingMode(QStackedLayout.StackAll)

        layout_stack.addWidget(self.label_gif)       # fundo
        layout_stack.addWidget(container_texto)     # frente

        return widget
    
    def envia_palavra(self):
        """Envia uma palavra simulando FPGA"""
        if not self.modo_jogo:
            QMessageBox.warning(self, "Erro", "Selecione o modo de jogo primeiro!")
            return
        index = self.combo_palavra.currentIndex()
        self.simulador.envia_palavra(index)
        self.label_instrucao.setText(
            f"✅ Palavra '{self.palavra_atual}' enviada!\n"
            f"Agora use 'CONFIRMAR LETRA' para simular acertos."
        )
    
    def confirma_letra(self):
        """Apenas pede ao simulador para envio de uma letra"""
        if not self.simulador.palavra_atual:
            QMessageBox.warning(self, "Aviso", "Envie uma palavra primeiro!")
            return
        
        # O simulador vai chamar o callback 'processa_letra' automaticamente
        sucesso = self.simulador.envia_proxima_letra()
        
        if not sucesso:
            self.label_mensagem.setText("🎉 Palavra Completa!")
    
    def simula_erro(self):
        self.erros += 1

        self.atualiza_ui_erros()

        # 🔥 verifica derrota
        if self.erros >= self.max_erros:
            self.ir_para_derrota()

    
    def reseta_jogo(self):
        """Reseta o jogo"""
        self.palavra_atual = ""
        self.indice_letra = 0
        self.contador_erros = 0
        self.erros = 0
        self.atualiza_ui_erros()
        self.display_palavra.reseta()
        self.label_vidas.setText("❤️❤️❤️")
        self.label_erros.setText("Erros: 0")
        self.label_mensagem.setText("")
        self.label_instrucao.setText(
            "👉 Use a aba 'Controles de Demo' para simular:\n"
            "   1. Enviar palavra\n"
            "   2. Confirmar letras (acertos)\n"
            "   3. Simular erros\n"
            "   4. Reset do jogo"
        )
        self.label_status.setText("Status: Aguardo você enviar uma palavra")
    
    def proxima_palavra(self):
        """Muda para próxima palavra"""
        self.simulador.proxima_palavra()
        self.combo_palavra.setCurrentIndex(self.simulador.palavra_index)
    
    def anterior_palavra(self):
        """Muda para palavra anterior"""
        self.simulador.palavra_anterior()
        self.combo_palavra.setCurrentIndex(self.simulador.palavra_index)
    
    def inicia_demo_automatica(self):
        """Inicia demonstração automática"""
        if not self.simulador.palavra_atual:
            # Primeiro envia uma palavra
            self.envia_palavra()
            return
        
        # Desabilita botão
        self.botao_auto.setEnabled(False)
        
        # Thread para demo automática
        def demo_automatica():
            intervalo = self.spin_intervalo.value() / 1000.0  # converter para segundos
            
            while self.simulador.indice_letra < len(self.simulador.palavra_atual):
                time.sleep(intervalo)
                self.letra_recebida.emit(self.simulador.palavra_atual[self.simulador.indice_letra])
                self.simulador.indice_letra += 1
            
            # Ao término
            QTimer.singleShot(0, lambda: self.botao_auto.setEnabled(True))
        
        thread = threading.Thread(target=demo_automatica, daemon=True)
        thread.start()
    
    @pyqtSlot(str)
    def processa_palavra(self, palavra: str):
        """Processa palavra recebida"""
        self.palavra_atual = palavra
        self.indice_letra = 0
        self.contador_erros = 0
        
        print(f"[DEMO] Palavra: {palavra}")
        self.tabs.setCurrentWidget(self.tela_jogo)
        self.display_palavra.configura_palavra(palavra)
        self.label_erros.setText("Erros: 0")
        self.label_status.setText(f"Status: Palavra '{palavra}' iniciada!")
        self.label_mensagem.setText("Selecione a primeira letra!")
    
    @pyqtSlot(str)
    def processa_letra(self, letra: str):
        self.display_palavra.marca_acerto()

        # CORREÇÃO: Comparação exata com o texto do Combo ou use 'in'
        if "Iniciante" in self.modo_jogo:
            self.erros = 0
            self.atualiza_ui_erros()

        # Verifica vitória
        if self.display_palavra.letras_acertadas >= len(self.palavra_atual):
            QTimer.singleShot(500, self.ir_para_vitoria) # Delay suave para ver a última letra
    
    def ir_para_vitoria(self):
        self.tabs.setCurrentWidget(self.tela_vitoria)
        self.movie.start() # Garante que o confete comece a cair

    def ir_para_derrota(self):
        self.label_mensagem.setText("💀 Fim de jogo!")
        self.tabs.setCurrentWidget(self.tela_derrota)

    def atualiza_ui_erros(self):
        self.label_erros.setText(f"Erros: {self.erros}")

        coracoes = ""
        for i in range(self.max_erros - self.erros):
            coracoes += "❤️"

        for i in range(self.erros):
            coracoes += "🖤"

        self.label_vidas.setText(coracoes)
            
    def volta_inicio(self):
        self.reseta_jogo()
        self.tabs.setCurrentWidget(self.tela_inicio)

    def aplica_estilo_modo(self):
        if self.modo_jogo == "0: Iniciante":
            self.setStyleSheet("""
                QWidget {
                    background-color: #E8F5E9;
                }
                QLabel {
                    color: #1B5E20;
                }
            """)

        elif self.modo_jogo == "1: Veterano":
            self.setStyleSheet("""
                QWidget {
                    background-color: #FFEBEE;
                }
                QLabel {
                    color: #B71C1C;
                }
            """)

    def mostra_controles_demo(self):
        dialog = QMessageBox(self)
        dialog.setWindowTitle("Controles Demo")
        dialog.setText("Escolha uma ação:")

        # Botões
        botao_palavra = dialog.addButton("Enviar Palavra", QMessageBox.ActionRole)
        botao_letra = dialog.addButton("Confirmar Letra", QMessageBox.ActionRole)
        botao_erro = dialog.addButton("Erro", QMessageBox.ActionRole)

        dialog.exec_()

        # Descobre qual botão foi clicado
        if dialog.clickedButton() == botao_palavra:
            self.envia_palavra()
        elif dialog.clickedButton() == botao_letra:
            self.confirma_letra()
        elif dialog.clickedButton() == botao_erro:
            self.simula_erro()


def main():
    """Função principal"""
    app = QApplication(sys.argv)
    
    # Estilo
    app.setStyle('Fusion')
    
    # Janela demo
    demo = DemoSomLetrando()
    demo.show()
    
    print("\n" + "=" * 70)
    print("🎮 SomLetrando - DEMO (Preview sem Hardware)")
    print("=" * 70)
    print("\n📝 INSTRUÇÕES:")
    print("  1. Use a aba 'Controles de Demo'")
    print("  2. Selecione uma palavra")
    print("  3. Clique 'ENVIAR PALAVRA'")
    print("  4. Clique 'CONFIRMAR LETRA' para simular acertos")
    print("  5. Use 'MODO AUTOMÁTICO' para ver demonstração")
    print("\n🎨 Cores carregadas de: config_somletrando.json")
    print("📏 Tamanhos carregados de: config_somletrando.json")
    print("\n💾 Modifique config_somletrando.json e reinicie para ver mudanças!")
    print("=" * 70 + "\n")
    
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()