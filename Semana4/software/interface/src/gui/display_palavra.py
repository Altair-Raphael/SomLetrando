"""
================================================================================
 Arquivo   : display_palavra.py
 Módulo    : src.gui
 Projeto   : SomLetrando
================================================================================
 Descrição : Widget customizado para exibir a palavra com cores
             - Preto: letras não selecionadas
             - Amarelo: letra atual a ser selecionada
             - Verde: letras já corretamente selecionadas
================================================================================
"""

from PyQt5.QtWidgets import QWidget, QHBoxLayout, QLabel
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont

try:
    from ..config import config
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
except:
    # Fallback se não conseguir importar config
    def obtem_cor(chave: str, padrao: str = "#000000") -> str:
        return padrao
    
    def obtem_tamanho_fonte(chave: str, padrao: int = 12) -> int:
        return padrao


class DisplayPalavra(QWidget):
    """
    Widget customizado para exibir a palavra com cores
    - Preto: letras não selecionadas ainda
    - Amarelo: letra atual a ser selecionada
    - Verde: letras já corretamente selecionadas
    """
    
    def __init__(self):
        super().__init__()
        self.palavra = ""
        self.indice_atual = 0
        self.letras_acertadas = 0
        self.inicializa_ui()
        
    def inicializa_ui(self):
        """Configura a UI do display"""
        self.layout = QHBoxLayout()
        self.layout.setContentsMargins(20, 20, 20, 20)
        self.layout.setSpacing(obtem_tamanho_fonte("tamanho_palavra_letras", 10))
        self.setLayout(self.layout)
        
        self.labels_letras = []
        background_color = obtem_cor("fundo_display", "#ffffff")
        self.setStyleSheet(f"background-color: {background_color}; border-radius: 10px;")
        
    def configura_palavra(self, palavra: str):
        """Configura a palavra a ser exibida"""
        self.palavra = palavra.upper()
        self.indice_atual = 0
        self.letras_acertadas = 0
        
        # Limpa labels anteriores
        while self.layout.count():
            child = self.layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()
        
        self.labels_letras = []
        
        # Cria label para cada letra
        for i, letra in enumerate(self.palavra):
            label = QLabel(letra)
            fonte = QFont()
            fonte.setPointSize(obtem_tamanho_fonte("tamanho_palavra_letras", 48))
            fonte.setBold(True)
            label.setFont(fonte)
            label.setAlignment(Qt.AlignCenter)
            
            # Primeira letra em amarelo, resto em preto
            if i == 0:
                cor_atual = obtem_cor("letra_atual", "#FFD700")
                label.setStyleSheet(f"color: {cor_atual}; padding: 10px;")
            else:
                cor_nao_selecionada = obtem_cor("letra_nao_selecionada", "#000000")
                label.setStyleSheet(f"color: {cor_nao_selecionada}; padding: 10px;")
            
            self.labels_letras.append(label)
            self.layout.addWidget(label)
    
    def marca_acerto(self):
        """Marca a letra atual como acertada (verde) e avança"""
        if self.indice_atual < len(self.labels_letras):
            cor_acertada = obtem_cor("letra_acertada", "#00AA00")
            self.labels_letras[self.indice_atual].setStyleSheet(
                f"color: {cor_acertada}; padding: 10px;"
            )
            self.indice_atual += 1
            self.letras_acertadas += 1
            
            # Muda próxima letra para amarelo
            if self.indice_atual < len(self.labels_letras):
                cor_atual = obtem_cor("letra_atual", "#FFD700")
                self.labels_letras[self.indice_atual].setStyleSheet(
                    f"color: {cor_atual}; padding: 10px;"
                )
    
    def reseta(self):
        """Reseta o display para estado inicial"""
        self.palavra = ""
        self.indice_atual = 0
        self.letras_acertadas = 0
        while self.layout.count():
            child = self.layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()
        self.labels_letras = []