from typing import List

from termcolor import cprint

from .utils import separator, error

class MenuEntry:
    def __init__(self, name: str, function: callable = lambda: None):
        self.name = name
        self.function = function

    def __str__(self):
        return self.name

    def __call__(self):
        self.function()


def _menu_entry(option: int, text: str):
    cprint(f'{option}.', 'blue', end=' ')
    cprint(f'{text}', 'green')


def menu(entries: List[MenuEntry], title='', width=20):
    while True:
        try:
            # Print Menu Options
            print()
            separator(width, title)
            
            cprint('Opções:', 'green')
            
            for i, entry in enumerate(entries):
                _menu_entry(i+1, entry.name)
            _menu_entry(0, 'Sair')
            
            separator(width)
    
            # Get User Input
            cprint('>', 'blue', end=' ')
            choice = input()
            
            if choice == '0':
                break
            
            if not choice.isdigit():
                error('Operação deve ser um número')
                continue
            
            if int(choice) > len(entries):
                error('Operação inválida')
                continue
            
            # Execute Function
            entries[int(choice)-1]()
            
        # Handle Exceptions
        except KeyboardInterrupt:
            cprint('\n\nEncerrando...', 'red')
            exit(0)
        except Exception as e:
            error(e)
            continue

    cprint('\nSaindo...', 'yellow')