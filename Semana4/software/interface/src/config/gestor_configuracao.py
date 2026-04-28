"""
================================================================================
 Arquivo   : gestor_configuracao.py
 Projeto   : SomLetrando
================================================================================
 Descrição : Gerenciador de configurações baseado em JSON
             Permite customização visual e comportamental sem editar código
================================================================================
"""

import json
import os
from typing import Any, Dict, Optional
from pathlib import Path


class GestorConfiguracao:
    """Gerencia configurações da aplicação a partir de arquivo JSON"""
    
    _instancia = None  # Singleton
    
    def __new__(cls):
        if cls._instancia is None:
            cls._instancia = super(GestorConfiguracao, cls).__new__(cls)
            cls._instancia._inicializado = False
        return cls._instancia
    
    def __init__(self):
        if self._inicializado:
            return
        
        self._inicializado = True
        self.configuracoes = {}
        self.arquivo_config = self._encontra_config()
        
        if self.arquivo_config:
            self.carrega()
        else:
            print("[CONFIG] Arquivo de configuração não encontrado. Usando defaults.")
            self.configuracoes = self._defaults()
    
    @staticmethod
    def _encontra_config() -> Optional[str]:
        """Procura pelo arquivo de configuração em locais padrão"""
        localizacoes = [
            "configs/config_somletrando.json",
            "config_somletrando.json",
            os.path.join(os.path.dirname(__file__), "../../config_somletrando.json"),
            os.path.join(os.path.dirname(__file__), "../../configs/config_somletrando.json"),
            os.path.expanduser("~/.somletrando/config.json"),
        ]
        
        for loc in localizacoes:
            if os.path.exists(loc):
                print(f"[CONFIG] Arquivo encontrado: {loc}")
                return loc
        
        return None
    
    @staticmethod
    def _defaults() -> Dict:
        """Retorna configurações padrão"""
        return {
            "interface": {
                "titulo": "SomLetrando",
                "largura_janela": 1200,
                "altura_janela": 600,
            },
            "cores": {
                "fundo_principal": "#f0f0f0",
                "letra_nao_selecionada": "#000000",
                "letra_atual": "#FFD700",
                "letra_acertada": "#00AA00",
                "letra_erro": "#CC0000",
                "texto_vitoria": "#006600",
                "texto_derrota": "#660000",
            },
            "fontes": {
                "tamanho_palavra_letras": 48,
                "tamanho_status": 14,
                "tamanho_mensagem_grande": 24,
            },
            "serial": {
                "baudrate_padrao": 9600,
                "bytesize": 7,
                "stopbits": 2,
            },
            "comportamento": {
                "tempo_mensagem_acerto_ms": 1000,
                "auto_detectar_porta": True,
            }
        }
    
    def carrega(self) -> bool:
        """
        Carrega configurações do arquivo JSON
        
        Returns:
            True se carregou com sucesso, False caso contrário
        """
        if not self.arquivo_config:
            self.configuracoes = self._defaults()
            return False
        
        try:
            with open(self.arquivo_config, 'r', encoding='utf-8') as f:
                config_lida = json.load(f)
            
            # Merge com defaults para garantir todas as chaves existem
            self.configuracoes = self._merge_config(self._defaults(), config_lida)
            print(f"[CONFIG] Configurações carregadas com sucesso")
            return True
        
        except json.JSONDecodeError as e:
            print(f"[CONFIG] Erro ao parsear JSON: {e}")
            self.configuracoes = self._defaults()
            return False
        
        except IOError as e:
            print(f"[CONFIG] Erro ao ler arquivo: {e}")
            self.configuracoes = self._defaults()
            return False
    
    @staticmethod
    def _merge_config(defaults: Dict, custom: Dict) -> Dict:
        """Merge customizado recusivamente com defaults"""
        resultado = defaults.copy()
        
        for chave, valor in custom.items():
            if isinstance(valor, dict) and chave in resultado:
                resultado[chave] = GestorConfiguracao._merge_config(
                    resultado[chave], valor
                )
            else:
                resultado[chave] = valor
        
        return resultado
    
    def get(self, chave: str, padrao: Any = None) -> Any:
        """
        Obtém valor de configuração usando notação de ponto
        
        Exemplo:
            gestor.get("cores.letra_atual")           → "#FFD700"
            gestor.get("fontes.tamanho_palavra_letras") → 48
            gestor.get("inexistente", "valor_padrao")  → "valor_padrao"
        
        Args:
            chave: Chave em formato "secao.subsecao.chave" ou "secao.chave"
            padrao: Valor padrão se chave não encontrada
        
        Returns:
            Valor da configuração ou padrao se não encontrado
        """
        partes = chave.split('.')
        valor = self.configuracoes
        
        try:
            for parte in partes:
                valor = valor[parte]
            return valor
        
        except (KeyError, TypeError):
            if padrao is not None:
                return padrao
            raise KeyError(f"Configuração não encontrada: {chave}")
    
    def set(self, chave: str, valor: Any) -> bool:
        """
        Configura valor de configuração em runtime
        
        Args:
            chave: Chave em formato "secao.subsecao.chave"
            valor: Novo valor
        
        Returns:
            True se sucesso, False caso contrário
        """
        partes = chave.split('.')
        dicionario = self.configuracoes
        
        try:
            for parte in partes[:-1]:
                if parte not in dicionario:
                    dicionario[parte] = {}
                dicionario = dicionario[parte]
            
            dicionario[partes[-1]] = valor
            print(f"[CONFIG] {chave} = {valor}")
            return True
        
        except Exception as e:
            print(f"[CONFIG] Erro ao configurar {chave}: {e}")
            return False
    
    def salva(self, caminho: Optional[str] = None) -> bool:
        """
        Salva configurações em arquivo JSON
        
        Args:
            caminho: Caminho onde salvar (usa arquivo original se None)
        
        Returns:
            True se sucesso, False caso contrário
        """
        arquivo = caminho or self.arquivo_config
        
        if not arquivo:
            print("[CONFIG] Nenhum caminho especificado para salvar")
            return False
        
        try:
            # Cria diretório se necessário
            diretorio = os.path.dirname(arquivo)
            if diretorio and not os.path.exists(diretorio):
                os.makedirs(diretorio)
            
            with open(arquivo, 'w', encoding='utf-8') as f:
                json.dump(self.configuracoes, f, indent=2, ensure_ascii=False)
            
            print(f"[CONFIG] Configurações salvas em {arquivo}")
            return True
        
        except IOError as e:
            print(f"[CONFIG] Erro ao salvar: {e}")
            return False
    
    def lista_tudo(self) -> Dict:
        """Retorna dicionário completo de configurações"""
        return self.configuracoes
    
    def recarrega(self) -> bool:
        """Recarrega configurações do arquivo"""
        return self.carrega()


# Instância global para usar em toda aplicação
config = GestorConfiguracao()