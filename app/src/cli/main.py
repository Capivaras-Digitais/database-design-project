from .menu import menu, MenuEntry
from .user import user_menu

def main_menu():
    menu([MenuEntry('Gerenciar Usuários', user_menu)], 'Início')
    
    
if __name__ == '__main__':
    main_menu()
