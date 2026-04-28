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
from typing import Optional
from enum import Enum

from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, 
    QLabel, QPushButton, QComboBox, QSpinBox, QStatusBar, QMessageBox
)
from PyQt5.QtCore import Qt, QThread, pyqtSignal, pyqtSlot, QTimer
from PyQt5.QtGui import QFont, QIcon

# Importa modulos locais
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
    """Obtém cor da configuração com fallback para padrão"""
    if config is None:
        return padrao
    try:
        return config.get(f"cores.{chave}", padrao)
    except:
        return padrao


def obtem_tamanho_fonte(chave: str, padrao: int = 12) -> int:
    """Obtém tamanho de fonte da configuração com fallback"""
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
        self.restante = bytearray()
        
    def run(self):
        """Executa thread de leitura serial"""
        try:
            self.serie = serial.Serial(
                self.porta, 
                self.baudrate, 
                bytesize=self.bytesize, 
                stopbits=self.stopbits,
                timeout=1
            )
            print(f"[SERIAL] Conectado em {self.porta}")
            self.conexao_estabelecida.emit()
            
            while self.ativo:
                if self.serie.in_waiting > 0:
                    try:
                        dados = self.serie.read(1)
                        
                        if self.restante:
                            dados = self.restante + dados
                            self.restante = bytearray()
                        
                        if b'\x00' in dados:
                            parts = dados.split(b'\x00')
                            mensagem = parts[0].decode('ascii', errors='replace').strip()
                            self.restante = bytearray(b'\x00'.join(parts[1:]))
                            
                            if mensagem:
                                if len(mensagem) > 1:
                                    self.palavra_recebida.emit(mensagem)
                                    print(f"[SERIAL] Palavra: {mensagem}")
                                else:
                                    self.letra_recebida.emit(mensagem)
                                    print(f"[SERIAL] Letra: {mensagem}")
                        else:
                            if not self.restante:
                                self.restante = bytearray(dados)
                            else:
                                self.restante.extend(dados)
                    
                    except UnicodeDecodeError as e:
                        print(f"[SERIAL] Erro de decodificação: {e}")
                
                time.sleep(0.01)
        
        except serial.SerialException as e:
            self.erro_conexao.emit(f"Erro na porta serial: {e}")
            print(f"[SERIAL] Erro: {e}")
        
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
        
        self.estado = EstadoJogo.INICIAL
        self.palavra_atual = ""
        self.letra_esperada = ""
        self.contador_erros = 0
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
        
        # SEÇÃO: Informações 
        layout_info = QHBoxLayout()
        
        self.label_status = QLabel("Status: Conectando...")
        fonte_status = QFont()
        fonte_status.setPointSize(obtem_tamanho_fonte("tamanho_status", 14))
        fonte_status.setBold(True)
        self.label_status.setFont(fonte_status)
        layout_info.addWidget(self.label_status)
        
        layout_info.addStretch()
        
        self.label_erros = QLabel("Erros: 0")
        fonte_erros = QFont()
        fonte_erros.setPointSize(obtem_tamanho_fonte("tamanho_status", 14))
        fonte_erros.setBold(True)
        self.label_erros.setFont(fonte_erros)
        layout_info.addWidget(self.label_erros)
        
        layout_principal.addLayout(layout_info)
        
        # SEÇÃO: Display da Palavra
        self.display_palavra = DisplayPalavra()
        layout_principal.addWidget(self.display_palavra)
        
        # SEÇÃO: Mensagem Grande 
        self.label_mensagem = QLabel("")
        fonte_msg = QFont()
        fonte_msg.setPointSize(obtem_tamanho_fonte("tamanho_mensagem_grande", 24))
        fonte_msg.setBold(True)
        self.label_mensagem.setFont(fonte_msg)
        self.label_mensagem.setAlignment(Qt.AlignCenter)
        self.label_mensagem.setStyleSheet("color: #333333;")
        layout_principal.addWidget(self.label_mensagem)
        
        # SEÇÃO: Controles Serial 
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
        
        layout_serial.addStretch()
        
        self.botao_reset = QPushButton("Reset Jogo")
        self.botao_reset.clicked.connect(self.reseta_jogo)
        layout_serial.addWidget(self.botao_reset)
        
        layout_principal.addLayout(layout_serial)
        
        self.statusBar_widget = QStatusBar()
        self.setStatusBar(self.statusBar_widget)
        self.statusBar_widget.showMessage("Pronto. Aguardando conexão serial...")
        
    def atualiza_portas(self):
        """Lista portas seriais disponíveis"""
        self.combo_porta.clear()
        portas = serial.tools.list_ports.comports()
        
        if portas:
            for porta, desc, _ in portas:
                self.combo_porta.addItem(f"{porta} ({desc})", porta)
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
        self.label_mensagem.setText("Selecione a primeira letra!")
        
        self.statusBar_widget.showMessage(
            f"Palavra iniciada: {self.palavra_atual} | "
            f"Letra inicial: {self.palavra_atual[0]}"
        )
    
    @pyqtSlot(str)
    def processa_letra(self, letra: str):
        """Processa letra recebida da FPGA (sinaliza acerto)"""
        print(f"[GUI] Letra acertada: {letra}")
        
        if not self.palavra_atual:
            print("[GUI] Nenhuma palavra em progresso")
            return
        
        self.estado = EstadoJogo.ACERTO
        self.display_palavra.marca_acerto()
        
        if self.display_palavra.letras_acertadas >= len(self.palavra_atual):
            self.em_vitoria()
        else:
            proxima_letra = self.palavra_atual[self.display_palavra.indice_atual]
            self.atualiza_status(f"Acerto! Próxima letra: {proxima_letra}")
            self.label_mensagem.setText("✓ Correto! Próxima letra...")
            
            tempo_msg = 1000
            if config:
                try:
                    tempo_msg = config.get("comportamento.tempo_mensagem_acerto_ms", 1000)
                except:
                    pass
            
            QTimer.singleShot(tempo_msg, lambda: self.label_mensagem.setText(""))
            
            self.statusBar_widget.showMessage(
                f"Acertou {self.display_palavra.letras_acertadas}/"
                f"{len(self.palavra_atual)} | "
                f"Próxima: {proxima_letra}"
            )
    
    def em_vitoria(self):
        """Gerencia estado de vitória"""
        self.estado = EstadoJogo.VITORIA
        self.atualiza_status("VITÓRIA!")
        self.label_mensagem.setText("🎉 PARABÉNS! VOCÊ GANHOU! 🎉")
        cor_vitoria = obtem_cor("texto_vitoria", "#006600")
        self.label_mensagem.setStyleSheet(f"color: {cor_vitoria}; font-weight: bold;")
        self.statusBar_widget.showMessage("Jogo finalizado com VITÓRIA! Aguardando próximo jogo...")
    
    def em_derrota(self):
        """Gerencia estado de derrota"""
        self.estado = EstadoJogo.DERROTA
        self.atualiza_status("DERROTA!")
        self.label_mensagem.setText("Muitos erros! Pressione Reset para tentar novamente.")
        cor_derrota = obtem_cor("texto_derrota", "#660000")
        self.label_mensagem.setStyleSheet(f"color: {cor_derrota}; font-weight: bold;")
        self.statusBar_widget.showMessage("Jogo finalizado com DERROTA! Pressione Reset para tentar novamente.")
    
    def atualiza_status(self, mensagem: str):
        """Atualiza label de status"""
        self.label_status.setText(f"Status: {mensagem}")
    
    def reseta_jogo(self):
        """Reset do jogo"""
        self.estado = EstadoJogo.INICIAL
        self.palavra_atual = ""
        self.letra_esperada = ""
        self.contador_erros = 0
        
        self.display_palavra.reseta()
        self.label_erros.setText("Erros: 0")
        self.label_mensagem.setText("")
        self.label_mensagem.setStyleSheet("color: #333333;")
        self.atualiza_status("Aguardando palavra...")
        self.statusBar_widget.showMessage("Jogo resetado. Aguardando palavra...")
        
        print("[GUI] Jogo resetado")
    
    def criar_icone(self):
        """Cria um ícone para a janela (placeholder)"""
        icon = QIcon()
        return icon
    
    def closeEvent(self, event):
        """Gerencia fechamento da aplicação"""
        if self.trabalho_serial and self.trabalho_serial.isRunning():
            self.trabalho_serial.parar()
        event.accept()


def main():
    """Função principal"""
    app = QApplication(sys.argv)
    app.setStyle('Fusion')
    
    janela = TelaJogo()
    janela.show()
    
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()