from builddata import *
from zipfile import ZipFile
import argparse
import pathlib
import os
import platform
import re


class IGNORE:
    FOLDERS = r'(?:)'
    FILES = r'^(?:)$'


class IMPORT:
    FOLDER = '.import'
    FILE = r'(?:.+.import)'

    PATH_PATTERN = r'path="res:\/\/\.import\/{0}-([0-9a-fA-F]+?)\.stex"'


def write_file(zip: ZipFile, parent: pathlib.Path, file: pathlib.Path):
    print(f'{file.relative_to(parent)}')
    zip.write(file, file.relative_to(parent))


def copy_folder_to_zip(zip: ZipFile, parent: pathlib.Path, folder: pathlib.Path):
    if not folder.is_dir():
        return
    
    for file in folder.rglob("*"):
        if not file.is_file():
            continue
        
        folderpath = str(file.parent.relative_to(parent)).replace('\\', '/') + '/'
        if re.search(IGNORE.FOLDERS, folderpath):
            continue
        if re.match(IGNORE.FILES, file.name):
            continue
        
        if re.match(IMPORT.FILE, file.name):
            copy_import_to_zip(zip, parent, file)
            continue

        write_file(zip, parent, file)


def copy_import_to_zip(zip: ZipFile, parent: pathlib.Path, imp: pathlib.Path):
    write_file(zip, parent, imp)

    asset = imp.name[:-len('.import')]
    pattern = IMPORT.PATH_PATTERN.format(asset.replace('.', '\.'))

    with open(imp, 'r') as file:
        content = file.read()
        
        match = re.search(pattern, content)
        if not match:
            return
        hash = match.group(1)
        
        imports = parent.joinpath('.import')

        stex = imports.joinpath(f'{asset}-{hash}.stex')
        md5 = imports.joinpath(f'{asset}-{hash}.md5')

        if not pathlib.Path(stex).exists():
            return
        
        print(f'HASH: {hash}')
        write_file(zip, parent, stex)
        write_file(zip, parent, md5)


mod_dir = os.getcwd()


def zip_mod():
    print('Zipping mod...')
    
    os.chdir(mod_dir)

    path = pathlib.Path(f'{YOMIH_PATH}/mods/{MOD_NAME}{MOD_SUFFIX}.zip')
    
    if path.exists():
        os.remove(path)
    zip = ZipFile(path, 'w')

    parent = pathlib.Path('..').resolve()
    folder = pathlib.Path('.').resolve()
    copy_folder_to_zip(zip, parent, folder)

    print('Done zipping!')
    print(f'Mod exported to {path}')
    print('')


def run_game():
    print('Running game...')

    os.chdir(YOMIH_PATH)

    print(os.getcwd())

    if platform.system() == 'Linux':
        os.system('./YourOnlyMoveIsHUSTLE.x86_64')
    elif platform.system() == 'Windows':
        os.system('YourOnlyMoveIsHUSTLE.exe')
    else:
        raise NotImplementedError(f'Cannot run game for platform: {platform.system()}')
    
    print('')


def populate_ignore():
    print('Populating .buildignore...')

    IGNORE.FOLDERS = r''
    IGNORE.FILES = r''

    folders = []
    files = []

    def recursive_scan(folder: pathlib.Path):
        buildignore = folder.joinpath('.buildignore')
        folderstr = str(folder).replace('\\', '/') + '/'
        if folderstr == './':
            folderstr = ''
        
        if not buildignore.exists():
            return

        print(f'Reading .buildignore at {buildignore}')
        with open(buildignore, 'r') as file:
            lines = file.readlines()
            
        for l in lines:
            l = l.strip().replace('\\', '/')

            if l.startswith('#') or len(l) == 0:
                continue

            if l.endswith('/'):
                print(f'Folder excluded: {l}')
                folders.append(folderstr + l.replace('*', '.+'))
            
            else:
                print(f'File excluded: {l}')
                files.append(l.replace('*', '.+'))
            
        for child in os.listdir(folder):
            if os.path.isfile(child):
                continue
            recursive_scan(pathlib.Path(child))

    recursive_scan(pathlib.Path())

    folders.append(IMPORT.FOLDER)

    IGNORE.FOLDERS = r'(?:' + r'|'.join((rf'(?:{x})' for x in folders)) + r')'
    IGNORE.FILES = r'^(?:' + r'|'.join((rf'(?:{x})' for x in files)) + r')$'

    print(f'Final Folder ignore: {IGNORE.FOLDERS}')
    print(f'Final File ignore: {IGNORE.FILES}')

    print('')


if __name__ == '__main__':
    if 'YOMIH_PATH' not in os.environ:
        print('Please add YOMIH_PATH to ENV!')

    populate_ignore()

    parser = argparse.ArgumentParser(
        prog='YomiHUSTLE Build Tools',
        description='YomiHUSTLE Python Toolset to Build and Test mods with ease',
        usage='build.py [args]')
    parser.add_argument('-z', '--zip', help='Zips the current mod and puts it in the game folder', action=argparse.BooleanOptionalAction)
    parser.add_argument('-p', '--pause', help='Pauses after every Zip or Run operation', action=argparse.BooleanOptionalAction)
    parser.add_argument('-r', '--run', help='Runs the game (without workshop mods)', action=argparse.BooleanOptionalAction)
    parser.add_argument('-l', '--loop', help='Repeats the process N times (-1 for infinity)', default=1, type=int)

    args = parser.parse_args()

    count = 0
    verbose_loop = False
    infinite_loop = args.loop == -1
    if args.loop != 1:
        verbose_loop = True
        print(f'Running loop {"INFINITE" if infinite_loop else args.loop} times')

    while count < args.loop or infinite_loop:
        count += 1
        if verbose_loop:
            print(f'Loop iteration: {count}')

        if args.zip:
            zip_mod()
            if args.pause:
                input()
        
        if args.run:
            run_game()
            if args.pause:
                input()
