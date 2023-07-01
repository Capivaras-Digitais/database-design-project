from termcolor import cprint, COLORS

from model.usuario import Usuario, list_usuarios, insert_usuario, get_usuario, search_usuarios

from .menu import menu, MenuEntry
from .utils import error, success

def print_user(user: Usuario):
        cprint(f'PK - {user.nome}', 'cyan')
        cprint(f'    Nome:', 'cyan', end=' ')
        cprint(f'{user.nome}', 'white')
        cprint(f'    Email:', 'cyan', end=' ')
        cprint(f'{user.email}', 'white')
        cprint(f'    Senha:', 'cyan', end=' ')
        cprint(f'{user.senha}', 'white')
        cprint(f'    Admin:', 'cyan', end=' ')
        cprint(f'{user.admin}', 'white')

def list_users():
    users = list_usuarios()

    cprint('Usuários:', 'magenta')
    
    for user in users:
        print_user(user)
    
    cprint('Total:', 'magenta', end=' ')
    cprint(f'{len(users)}', 'white')
        

def get_user():
    cprint('Nome>', 'cyan', end=' ')
    nome = input()

    user = get_usuario(nome)

    if user is None:
        error('Usuário não encontrado')
        return
    
    print_user(user)

def search_users():
    cprint('Query (email e nome)>', 'cyan', end=' ')
    query = input()
    
    results = search_usuarios(query)

    for user in results:
        print_user(user)
    
    cprint('Total:', 'magenta', end=' ')
    cprint(f'{len(results)}', 'white')

def create_user():
    cprint('Criar Usuário:', 'magenta')
    
    cprint('Nome>', 'cyan', end=' ')
    nome = input()
    
    cprint('Email (opcional)>', 'cyan', end=' ')
    email = input() or None
    
    cprint('Senha>', 'cyan', end=' ')
    senha = input() or None
    
    cprint('Admin (s/N)>', 'cyan', end=' ')
    admin = input().lower() == 's'
    
    try:
        user = insert_usuario(Usuario(nome, senha, email, admin))
        success(f'Usuário {user.nome} criado com sucesso!')
    except Exception as e:
        error(str(e))


def user_menu():
    menu([
            MenuEntry('Criar usuário', create_user),
            MenuEntry('Obter usuário', get_user),
            MenuEntry('Procurar usuários', search_users),
            MenuEntry('Listar todos usuários', list_users), 
        ], 'Menu: Usuário')
