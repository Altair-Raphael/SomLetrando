#!/usr/bin/env python3
"""
================================================================================
 Arquivo   : interface_principal.py
 Módulo    : src.gui
 Projeto   : SomLetrando
================================================================================
 Descrição : Interface gráfica (GUI) para o jogo SomLetrando
             Exibe a palavra atual, destaca a letra a digitar e marca acertos
================================================================================
"""

import sys
import serial
import serial.tools.list_ports
import threading
import time
import os
from typing import Optional
from enum import Enum
from pathlib import Path

from gtts import gTTS
import pygame

from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, 
    QLabel, QPushButton, QComboBox, QSpinBox, QStackedWidget, QStatusBar, QMessageBox, QProgressBar, QSizePolicy
)
from PyQt5.QtCore import Qt, QThread, pyqtSignal, pyqtSlot, QTimer
from PyQt5.QtGui import QFont, QIcon
from PyQt5.QtWidgets import QStackedLayout
from PyQt5.QtGui import QMovie
from PyQt5.QtGui import QPixmap
from PyQt5.QtWidgets import QGraphicsOpacityEffect

# Importa módulos locais
from .display_palavra import DisplayPalavra
try:
    from ..config import config
except ImportError:
    print("[WARNING] Gestor de configurações não encontrado. Usando valores padrão.")
    config = None


class EstadoJogo(Enum):
    """Estados possíveis do jogo"""
    INICIAL = 0
    AGUARDANDO = 1
    LETRA_RECEBIDA = 2
    ACERTO = 3
    ERRO = 4
    VITORIA = 5
    DERROTA = 6


def obtem_cor(chave: str, padrao: str = "#000000") -> str:
    """Cor da configuração"""
    if config is None:
        return padrao
    try:
        return config.get(f"cores.{chave}", padrao)
    except:
        return padrao


def obtem_tamanho_fonte(chave: str, padrao: int = 12) -> int:
    """tamanho de fonte da configuração"""
    if config is None:
        return padrao
    try:
        return config.get(f"fontes.{chave}", padrao)
    except:
        return padrao


class TrabalhadoSerial(QThread):
    """
    Thread para gerenciar comunicação serial de forma assíncrona
    Evita travamentos na UI enquanto aguarda dados
    """
    # Sinais
    palavra_recebida = pyqtSignal(str)
    letra_recebida = pyqtSignal(str)
    ajuda_recebida = pyqtSignal(str)

    modo_recebido = pyqtSignal(int)
    confirmar_recebido = pyqtSignal()
    iniciar_recebido = pyqtSignal()
    reset_recebido = pyqtSignal()

    erro_conexao = pyqtSignal(str)
    conexao_estabelecida = pyqtSignal()
    desconectado = pyqtSignal()
    
    
    def __init__(self, porta: str, baudrate: int = 9600, bytesize: int = 7, stopbits: int = 2):
        super().__init__()
        self.porta = porta
        self.baudrate = baudrate
        self.bytesize = bytesize
        self.stopbits = stopbits
        self.serie = None
        self.ativo = True
        self.mensagem_buffer = bytearray()
        self.aguardando_modo = False
        # Mitigacao: apos reset, descarta payload textual por uma janela curta.
        self.descarta_payload_ate = 0.0
        self.janela_quarentena_reset_s = 0.18
        self.apos_iniciar = False
        self.aguardando_ajuda = False
        
    def falar_texto(self, texto: str):
        """Fala texto usando gTTS e pygame para voz amigável"""
        try:
            tts = gTTS(text=texto, lang='pt', slow=False)
            tts.save("temp_audio.mp3")
            pygame.mixer.init()
            pygame.mixer.music.load("temp_audio.mp3")
            pygame.mixer.music.play()
            while pygame.mixer.music.get_busy():
                time.sleep(0.1)
            pygame.mixer.music.stop()
            pygame.mixer.quit()
            os.remove("temp_audio.mp3")
        except Exception as e:
            print(f"Erro na fala: {e}")
        
    def run(self):
        """Executa thread de leitura serial"""
        try:
            self.serie = serial.Serial(
                self.porta,
                self.baudrate,
                bytesize=self.bytesize,
                stopbits=self.stopbits,
                timeout=0.05
            )
            print(f"Conectado {self.porta}")
            self.conexao_estabelecida.emit()

            while self.ativo:
                agora = time.monotonic()
                n = self.serie.in_waiting
                if n > 0:
                    dados = self.serie.read(n)
                    for byte in dados:
                        # Terminador de payload textual (palavra/letra)
                        if byte == 0:
                            if agora < self.descarta_payload_ate:
                                self.mensagem_buffer.clear()
                                continue

                            mensagem = self.mensagem_buffer.decode('ascii', errors='replace').strip()
                            self.mensagem_buffer.clear()
                            if mensagem:
                                if self.aguardando_ajuda:
                                    self.ajuda_recebida.emit(mensagem)
                                    print(f"[FPGA] Ajuda: {mensagem}")
                                    self.falar_texto(mensagem)
                                elif len(mensagem) > 1 and not self.apos_iniciar:
                                    self.palavra_recebida.emit(mensagem)
                                    print(f"[FPGA] Palavra: {mensagem}")
                                    self.apos_iniciar = True
                                    self.falar_texto(f"A palavra escolhida é: {mensagem}")
                                else:
                                    self.letra_recebida.emit(mensagem)
                                    print(f"[FPGA] Letra: {mensagem}")
                                    self.falar_texto(mensagem)
                            self.aguardando_ajuda = False
                            continue

                        ch = chr(byte)

                        # Outros sinais transmitidos por serial (jogar, modo, ajuda, confirmacao e reset)
                        if ch == '*':
                            self.iniciar_recebido.emit()
                            self.aguardando_modo = True
                            print("[FPGA] Iniciar recebido")
                            continue

                        if ch == '?':
                            # Payload de ajuda nao deve entrar no fluxo da jogada parcial
                            self.mensagem_buffer.clear()
                            self.aguardando_ajuda = True
                            print("[FPGA] Sinal de ajuda recebido")
                            continue

                        if ch in ('<', '>') and self.aguardando_modo:
                            self.modo_recebido.emit(1 if ch == '>' else 0)
                            self.aguardando_modo = False
                            print(f"[FPGA] Modo recebido: {ch}")
                            continue

                        if ch == '~':
                            self.confirmar_recebido.emit()
                            print("[FPGA] Confirmacao recebida")
                            continue

                        if ch == '^':
                            self.mensagem_buffer.clear()
                            self.descarta_payload_ate = agora + self.janela_quarentena_reset_s
                            self.aguardando_modo = False
                            self.apos_iniciar = False
                            self.aguardando_ajuda = False
                            self.reset_recebido.emit()
                            print("[FPGA] Reset recebido")
                            continue

                        # Qualquer outro byte ASCII imprimivel faz parte do payload.
                        if 32 <= byte <= 126:
                            self.mensagem_buffer.append(byte)
                time.sleep(0.01)

        except KeyboardInterrupt:
            print("Fim")
        
        finally:
            if self.serie and self.serie.is_open:
                self.serie.close()
                print("[SERIAL] Desconectado")
                self.desconectado.emit()
    
    def parar(self):
        """Para a thread de forma segura"""
        self.ativo = False
        self.wait()


class TelaJogo(QMainWindow):
    """Janela principal do jogo SomLetrando"""
    
    def __init__(self):
        super().__init__()
        
        largura = 1200
        altura = 600
        titulo = "SomLetrando - Jogo de Consciência Fonológica"
        
        if config:
            try:
                largura = config.get("interface.largura_janela", largura)
                altura = config.get("interface.altura_janela", altura)
                titulo = config.get("interface.titulo", titulo)
            except:
                pass
        
        self.setWindowTitle(titulo)
        self.setGeometry(100, 100, largura, altura)
        self.setWindowIcon(self.criar_icone())
        # Cor padrão da tela inicial (neutra)
        self.setStyleSheet("QMainWindow { background-color: #f0f0f0; }")
        self.modo_jogo = "0: Iniciante"
        self.contador_erros = 0
        self.max_erros = 3
        self.letra_pendente = "" #Variável que armazena a letra anterior a apertar confirmar
        self.estado = EstadoJogo.INICIAL
        self.palavra_atual = ""
        self.letra_esperada = ""
        self.trabalho_serial = None
        
        self.inicializa_ui()
        self.conecta_serial()
        
    def inicializa_ui(self):
        """Configura a interface gráfica"""
        widget_central = QWidget()
        self.setCentralWidget(widget_central)
        layout_principal = QVBoxLayout(widget_central)
        layout_principal.setContentsMargins(20, 20, 20, 20)
        layout_principal.setSpacing(20)

        self.stack = QStackedWidget()
        self.stack.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)

        # Cria as telas
        self.tela_inicio = self.cria_tela_inicial()
        self.tela_jogo = self.cria_aba_jogo()
        self.tela_vitoria = self.cria_tela_vitoria()
        self.tela_derrota = self.cria_tela_derrota()
        self.tela_config = self.cria_aba_configuracao() # Aba para Serial

        # Adicionar as abas ao widget
        self.stack.addWidget(self.tela_inicio)
        self.stack.addWidget(self.tela_jogo)
        self.stack.addWidget(self.tela_vitoria)
        self.stack.addWidget(self.tela_derrota)
        self.stack.addWidget(self.tela_config)

        layout_principal.addWidget(self.stack, 1)

        # Barra de Status (Fica sempre visível no rodapé)
        self.statusBar_widget = QStatusBar()
        self.setStatusBar(self.statusBar_widget)
        self.statusBar_widget.showMessage("Sistema Iniciado. Aguardando Hardware...")
    
    def cria_aba_configuracao(self):
        # ===== SEÇÃO: Controles Serial =====
        aba = QWidget()
        layout = QHBoxLayout(aba)
        
        layout_serial = QHBoxLayout()
        label_porta = QLabel("Porta Serial:")
        self.combo_porta = QComboBox()
        self.atualiza_portas()
        layout_serial.addWidget(label_porta)
        layout_serial.addWidget(self.combo_porta)
        
        label_baud = QLabel("Baud Rate:")
        self.spin_baud = QSpinBox()
        self.spin_baud.setValue(9600)
        self.spin_baud.setRange(9600, 115200)
        layout_serial.addWidget(label_baud)
        layout_serial.addWidget(self.spin_baud)
        
        self.botao_conectar = QPushButton("Conectar Serial")
        self.botao_conectar.clicked.connect(self.conecta_serial)
        layout_serial.addWidget(self.botao_conectar)

        layout.addLayout(layout_serial)
        layout.addStretch()

        return aba
        
    def cria_aba_jogo(self):
        """Cria a aba principal do jogo com o DisplayPalavra e Status"""
        aba = QWidget()
        layout = QVBoxLayout(aba)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(20)

        # Status
        layout_topo = QHBoxLayout()
        self.label_status = QLabel("Aguardando palavra...")
        fonte_status = QFont()
        fonte_status.setPointSize(14)
        fonte_status.setBold(True)
        self.label_status.setFont(fonte_status)

        self.label_erros = QLabel("Erros: 0")
        fonte_erros = QFont()
        fonte_erros.setPointSize(14)
        fonte_erros.setBold(True)
        self.label_erros.setFont(fonte_erros)

        self.label_vidas = QLabel("❤️❤️❤️")
        fonte_vidas = QFont("Segoe UI Emoji", 14)  # fonte que suporta emoji
        self.label_vidas.setFont(fonte_vidas)
        fonte_vidas.setPointSize(20)
        self.label_vidas.setFont(fonte_vidas)
        self.label_vidas.setAlignment(Qt.AlignCenter)

        layout_topo.addWidget(self.label_status)
        layout_topo.addStretch()
        layout_topo.addWidget(self.label_erros)
        layout_topo.addWidget(self.label_vidas)
        layout.addLayout(layout_topo)
        
        # ===== SEÇÃO: Barra de Progresso =====
        self.barra_progresso = QProgressBar()
        self.barra_progresso.setRange(0, 100)
        self.barra_progresso.setValue(0)
        self.barra_progresso.setFormat("Progresso: %p%")
        layout.addWidget(self.barra_progresso)
        
        # ===== SEÇÃO: Display da Palavra =====
        self.display_palavra = DisplayPalavra()
        layout.addWidget(self.display_palavra)
        
        # ===== SEÇÃO: Mensagem Grande =====
        self.label_mensagem = QLabel("")
        fonte_msg = QFont()
        fonte_msg.setPointSize(obtem_tamanho_fonte("tamanho_mensagem_grande", 24))
        fonte_msg.setBold(True)
        self.label_mensagem.setFont(fonte_msg)
        self.label_mensagem.setAlignment(Qt.AlignCenter)
        self.label_mensagem.setStyleSheet("color: #333333;")
        layout.addWidget(self.label_mensagem)

        return aba
        
    def atualiza_portas(self):
        self.combo_porta.clear()
        portas = serial.tools.list_ports.comports()
        
        if portas:
            for porta, desc, _ in portas:
                self.combo_porta.addItem(f"{porta} ({desc})", porta)

            index = self.combo_porta.findData("COM5")
            if index != -1:
                self.combo_porta.setCurrentIndex(index)
        else:
            self.combo_porta.addItem("Nenhuma porta encontrada", "")
        
    def conecta_serial(self):
        """Inicia conexão serial"""
        if self.trabalho_serial and self.trabalho_serial.isRunning():
            self.trabalho_serial.parar()
            self.botao_conectar.setText("Conectar Serial")
            return
        
        porta = self.combo_porta.currentData()
        if not porta:
            QMessageBox.warning(self, "Aviso", "Nenhuma porta serial disponível!")
            return
        
        baudrate = self.spin_baud.value()
        self.trabalho_serial = TrabalhadoSerial(porta, baudrate)

        self.trabalho_serial.palavra_recebida.connect(self.processa_palavra)
        self.trabalho_serial.letra_recebida.connect(self.processa_letra)
        self.trabalho_serial.ajuda_recebida.connect(self.processa_ajuda)

        self.trabalho_serial.modo_recebido.connect(self.troca_modo_jogo)
        self.trabalho_serial.confirmar_recebido.connect(self.confirmar_tentativa)
        self.trabalho_serial.iniciar_recebido.connect(self.prepara_para_jogo)
        self.trabalho_serial.reset_recebido.connect(self.volta_inicio)
       
        self.trabalho_serial.conexao_estabelecida.connect(self.em_conectado)
        self.trabalho_serial.erro_conexao.connect(self.em_erro_conexao)

        self.trabalho_serial.start()
        
        self.botao_conectar.setText("Desconectar Serial")
    
    @pyqtSlot()
    def em_conectado(self):
        """Callback quando conexão é estabelecida"""
        self.statusBar_widget.showMessage(f"Conectado! Aguardando palavra...")
        self.atualiza_status("Aguardando palavra...")
    
    @pyqtSlot(str)
    def em_erro_conexao(self, mensagem_erro: str):
        """Callback para erros de conexão"""
        QMessageBox.critical(self, "Erro de Conexão", mensagem_erro)
        self.botao_conectar.setText("Conectar Serial")
        self.atualiza_status("Erro de conexão")
    
    @pyqtSlot(str)
    def processa_palavra(self, palavra: str):
        """Processa palavra recebida da FPGA"""
        print(f"[GUI] Palavra recebida: {palavra}")

        self.palavra_atual = palavra.upper()
        self.contador_erros = 0
        self.estado = EstadoJogo.LETRA_RECEBIDA

        self.display_palavra.configura_palavra(self.palavra_atual)
        self.label_erros.setText("Erros: 0")
        self.atualiza_status(f"Palavra: {self.palavra_atual}")
        self.stack.setCurrentIndex(1)
        self.label_mensagem.setText("Selecione a primeira letra!")
        # Resetar barra de progresso
        self.barra_progresso.setValue(0)

        '''
        self.statusBar_widget.showMessage(
            f"Palavra iniciada: {self.palavra_atual} | "
            f"Letra inicial: {self.palavra_atual[0]}"
        )
        '''

    @pyqtSlot(str)
    def processa_letra(self, letra_recebida: str):
        """Armazena letra de FPGA"""
        self.letra_pendente = letra_recebida.upper().strip()

    @pyqtSlot(str)
    def processa_ajuda(self, ajuda_recebida: str):
        """Processa payload de ajuda sem alterar a jogada parcial pendente."""
        ajuda = ajuda_recebida.upper().strip()
        if not ajuda:
            return

        print(f"[GUI] Ajuda recebida: {ajuda}")


    @pyqtSlot()
    def confirmar_tentativa(self):
        """Executa a lógica de acerto/erro apenas quando o caractere '!' é recebido."""
        if not self.letra_pendente or not self.palavra_atual:
            return

        letra_esperada = self.palavra_atual[self.display_palavra.indice_atual].upper()

        if self.letra_pendente == letra_esperada:
            # --- ACERTO ---
            print(f"[GUI] Confirmado acerto: {self.letra_pendente}")
            if "0: Iniciante" in self.modo_jogo:
                self.contador_erros = 0  # Reseta erros apenas no modo Iniciante
            self.atualiza_ui_erros()
            self.display_palavra.marca_acerto()
            # Atualizar barra de progresso
            progresso = int((self.display_palavra.letras_acertadas / len(self.palavra_atual)) * 100)
            self.barra_progresso.setValue(progresso)
            
            if self.display_palavra.letras_acertadas >= len(self.palavra_atual):
                self.em_vitoria()
            else:
                self.label_mensagem.setText("✓ Correto!")
                self.label_mensagem.setStyleSheet("color: green;")
        else:
            # --- ERRO ---
            self.contador_erros += 1
            self.atualiza_ui_erros()
            self.label_mensagem.setText(f"❌ Errou! '{self.letra_pendente}' está incorreta.")
            self.label_mensagem.setStyleSheet("color: red;")

            # Se atingir o limite de 3 erros, o jogo termina em derrota
            if self.contador_erros >= self.max_erros:
                self.em_derrota()
                QTimer.singleShot(500, lambda: self.stack.setCurrentIndex(3))

        
        # Limpa a pendência após processar
        self.letra_pendente = ""

    @pyqtSlot(int)
    def troca_modo_jogo(self, modo: int):
        """Altera o modo de jogo apenas se estiver na tela inicial ou aguardando palavra"""
        if self.estado != EstadoJogo.INICIAL:
            self.statusBar_widget.showMessage("⚠️ Bloqueado: Não é possível mudar o modo durante o jogo!")
            return

        # Define o modo baseado no sinal recebido
        if modo == 1:
            self.modo_jogo = "1: Veterano"
            self.setStyleSheet("QMainWindow { background-color: #ffe6e6; }")  # Tom avermelhado para Veterano
        else:
            self.modo_jogo = "0: Iniciante"
            self.setStyleSheet("QMainWindow { background-color: #e6f7ff; }")  # Tom azulado para Iniciante
        
        self.statusBar_widget.showMessage(f"Modo alterado para: {self.modo_jogo}")
            
    def em_vitoria(self):
        """Gerencia estado de vitória"""
        self.estado = EstadoJogo.VITORIA
        self.atualiza_status("VITÓRIA!")
        self.label_mensagem.setText("🎉 PARABÉNS! VOCÊ GANHOU! 🎉")
        cor_vitoria = obtem_cor("texto_vitoria", "#006600")
        self.stack.setCurrentIndex(2)
        self.label_mensagem.setStyleSheet(f"color: {cor_vitoria}; font-weight: bold;")
        self.statusBar_widget.showMessage("Jogo finalizado com VITÓRIA! Aguardando próximo jogo...")
        self.tocar_som_vitoria()
    
    def em_derrota(self):
        """Gerencia estado de derrota"""
        self.estado = EstadoJogo.DERROTA
        self.atualiza_status("DERROTA!")
        self.label_mensagem.setText("Muitos erros! Pressione Reset para tentar novamente.")
        cor_derrota = obtem_cor("texto_derrota", "#660000")
        self.stack.setCurrentIndex(3)
        self.label_mensagem.setStyleSheet(f"color: {cor_derrota}; font-weight: bold;")
        self.statusBar_widget.showMessage("Jogo finalizado com DERROTA! Pressione Reset para tentar novamente.")
    
    def atualiza_status(self, mensagem: str):
        """Atualiza label de status"""
        self.label_status.setText(f"Status: {mensagem}")
    
    
    def cria_tela_inicial(self):
        widget = QWidget()
        layout = QVBoxLayout(widget)
        label_logo = QLabel()
        label_logo.setSizePolicy(QSizePolicy.Maximum, QSizePolicy.Maximum)
        label_logo.setMaximumSize(700, 400)
        caminho_logo = Path(__file__).resolve().parents[2] / "src/assets/Logov1.png"
        pixmap = QPixmap(str(caminho_logo))
        if not pixmap.isNull():
            label_logo.setPixmap(pixmap.scaled(700, 400, Qt.KeepAspectRatio, Qt.SmoothTransformation))
        label_logo.setAlignment(Qt.AlignCenter)

        self.label_status_inicio = QLabel("Aguardando início de partida...")
        self.label_status_inicio.setAlignment(Qt.AlignCenter)
        self.label_status_inicio.setStyleSheet("font-size: 20px;")

        # Botão para entrar no modo de espera do jogo
        botao_iniciar = QPushButton("▶️  Iniciar Partida")
        botao_iniciar.setStyleSheet("""
            QPushButton {
                background-color: #2196F3;
                color: white;
                font-size: 20px;
                padding: 12px;
                border-radius: 8px;
            }
            QPushButton:hover { background-color: #1976D2; }
        """)
        # Conecta a uma nova função que apenas muda a aba
        botao_iniciar.clicked.connect(self.prepara_para_jogo)

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
        layout.addWidget(label_logo, alignment=Qt.AlignHCenter)
        layout.addWidget(self.label_status_inicio)
        layout.addSpacing(30)
        layout_botoes = QVBoxLayout()
        layout_botoes.setSpacing(15)
        botao_iniciar.setFixedWidth(250)
        botao_como_jogar.setFixedWidth(250)
        layout_botoes.addWidget(botao_iniciar)
        layout_botoes.addWidget(botao_como_jogar)
        layout_botoes.setAlignment(Qt.AlignCenter)
        layout.addLayout(layout_botoes)
        layout.addStretch()

        return widget
    
    def prepara_para_jogo(self):
        """Vai para a aba de jogo e aguarda o envio da palavra pela FPGA"""
        if self.estado != EstadoJogo.INICIAL: return
        self.stack.setCurrentIndex(1) # Muda para a Aba 1 (Jogo)
        self.label_mensagem.setText("Aguardando palavra da FPGA...")
        self.label_mensagem.setStyleSheet("color: #555; font-style: italic;")
    
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
    
    def tocar_som_vitoria(self):
        """Toca som de vitória"""
        try:
            caminho_som = Path(__file__).resolve().parents[2] / "src/assets/vitoria.mp3"
            pygame.mixer.init()
            pygame.mixer.music.load(str(caminho_som))
            pygame.mixer.music.play()
        except Exception as e:
            print(f"Erro no som de vitória: {e}")
    
    def criar_icone(self):
        """Cria um ícone para a janela (placeholder)"""
        icon = QIcon()
        return icon
    
    def closeEvent(self, event):
        """Gerencia fechamento da aplicação"""
        if self.trabalho_serial and self.trabalho_serial.isRunning():
            self.trabalho_serial.parar()
        event.accept()
        
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

    def reseta_jogo(self):
        """Reset do jogo"""
        self.estado = EstadoJogo.INICIAL
        self.palavra_atual = ""
        self.letra_esperada = ""
        self.contador_erros = 0
        
        self.display_palavra.reseta()
        self.atualiza_ui_erros()

        self.label_mensagem.setText("")
        self.label_mensagem.setStyleSheet("color: #333333;")
        self.atualiza_status("Aguardando palavra...")
        self.statusBar_widget.setVisible(True)
        self.statusBar_widget.raise_()
        self.statusBar_widget.showMessage("Jogo resetado. Aguardando palavra...")
        self.stack.updateGeometry()
        
        print("[GUI] Jogo resetado")
        
    def volta_inicio(self):
        self.reseta_jogo()
        # Reseta para a cor da tela inicial
        self.setStyleSheet("QMainWindow { background-color: #f0f0f0; }")
        self.stack.setCurrentIndex(0)

    def atualiza_ui_erros(self):
        self.label_erros.setText(f"Erros: {self.contador_erros}")
        vidas_vivas = max(0, self.max_erros - self.contador_erros)
        coracoes = ("❤️" * vidas_vivas) + ("💔" * self.contador_erros)
        self.label_vidas.setText(coracoes)

def main():
        """Função principal"""
        app = QApplication(sys.argv)
        app.setStyle('Fusion')
        
        janela = TelaJogo()
        janela.show()
        sys.exit(app.exec_())


if __name__ == "__main__":
    main()