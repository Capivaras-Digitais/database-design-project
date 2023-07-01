from termcolor import cprint

def success(msg):
    cprint(f'Sucesso: {msg}', 'green')


def error(msg):
    cprint(f'Erro: {msg}', 'red')


def separator(width: int = 20, text: str = ''):
    if text:
        dashes = width - len(text) - 2
        r_dashes = dashes // 2
        l_dashes = dashes - r_dashes
        
        cprint('-'*l_dashes, 'green', end='')
        cprint(f' {text} ', 'white', end='')
        cprint('-'*r_dashes, 'green')
    else:
        cprint('-'*width, 'green')