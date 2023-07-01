import sys
import hashlib
import secrets
import re
from typing import Optional, List

from psycopg.errors import IntegrityError

from ._db import get_conn_pool

# The most powerful password check ever
PASSWORD_RE = re.compile(r'^[a-zA-Z\d]{1,}$')
KNOWN_CONSTRAINTS = {
    'pk_usuario': 'Já existe um usuário com esse nome',
    'ck_nome': 'Nome deve ter pelo menos 3 caracteres',
    'ck_admin_email': 'Administrador deve ter um email',
    'ck_proper_email': 'Email inválido',
}

##############
# Data Class #
##############

class Usuario:
    nome: str
    senha: str
    email: Optional[str]
    admin: bool

    def __init__(self, nome: str, senha: str, email: Optional[str], admin: bool):
        self.nome = nome
        self.senha = senha
        self.email = email
        self.admin = admin
        
    def __repr__(self):
        return f'Usuario(nome={self.nome}, senha={self.senha}, email={self.email}, admin={self.admin})'
    
    def __str__(self):
        return f'Usuario(nome={self.nome}, senha={self.senha}, email={self.email}, admin={self.admin})'

    def __eq__(self, other):
        if isinstance(other, Usuario):
            return self.nome == other.nome
        return False

    def to_dict(self):
        return {
            'nome': self.nome,
            'senha': self.senha,
            'email': self.email,
            'admin': self.admin
        }
        
    def to_tuple(self):
        return (self.nome, self.senha, self.email, self.admin)

    @staticmethod
    def from_dict(data: dict):
        return Usuario(data['nome'], data['senha'], data['email'], data['admin'])

    @staticmethod
    def from_tuple(data: tuple):
        return Usuario(data[0], data[1], data[2], data[3])


#################
# Hash Password #
#################

def hash_password(password: str, algorithm: str = 'sha256', rounds=2**11, salt_size=32) -> str:
    salt = secrets.token_hex(salt_size)
    ingest = password + salt
    
    for _ in range(rounds):
        ingest = hashlib.new(algorithm, ingest.encode('utf-8')).hexdigest()
    
    return f'{algorithm}${rounds}${salt}${ingest}'

#######################
# Database Operations #
#######################

def search_usuarios(query: str) -> List[Usuario]:
    """Search for usuarios in the database by a given query. The
    query will be tried to match against the textual fields "nome" and "email".

    Args:
        query (str): The query to search for.
        
    Returns:
        List[Usuario]: A list of usuarios that match the query.
    """

    with get_conn_pool().connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute('SELECT * FROM usuario WHERE nome ILIKE %s OR email ILIKE %s;', (f'%{query}%', f'%{query}%'))
            return [Usuario.from_tuple(row) for row in cursor.fetchall()]

def list_usuarios() -> List[Usuario]:
    """List all usuarios in the database.

    Returns:
        List[Usuario]: A list of all usuarios in the database.
    """
    
    with get_conn_pool().connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute('SELECT * FROM usuario;')
            return [Usuario.from_tuple(row) for row in cursor.fetchall()]
    
    
def insert_usuario(usuario: Usuario) -> Usuario:
    """Insert a usuario into the database.

    Args:
        usuario (Usuario): The usuario to insert.

    Returns:
        Usuario: The inserted usuario.
    """
    
    if PASSWORD_RE.match(usuario.senha) is None:
        raise Exception('Senha inválida')
    
    usuario.senha = hash_password(usuario.senha)
    
    with get_conn_pool().connection() as conn:
        with conn.cursor() as cursor: 
            try:
                cursor.execute('INSERT INTO usuario VALUES (%s, %s, %s, %s);', usuario.to_tuple())
                conn.commit()
                return usuario
            except IntegrityError as e:
                conn.rollback()
                for constraint, message in KNOWN_CONSTRAINTS.items():
                    if constraint in str(e):
                        raise Exception(message)
                raise Exception('Um erro inesperado ocorreu: ' + str(e))
            except Exception as e:
                print(repr(e), file=sys.stderr)
                conn.rollback()
                raise e


def get_usuario(nome: str) -> Optional[Usuario]:
    """Get a usuario from the database by nome.

    Args:
        nome (str): The nome of the usuario to get.

    Returns:
        Optional[Usuario]: The usuario if it exists, None otherwise.
    """
    
    with get_conn_pool().connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute('SELECT * FROM usuario WHERE nome = %s;', (nome,))
            row = cursor.fetchone()
            if row is None:
                return None
            return Usuario.from_tuple(row)
