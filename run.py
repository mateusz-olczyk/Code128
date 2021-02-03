#!/usr/bin/env python3

import os
import subprocess
import sys
from typing import Any, List, Optional


def find_cmd_in_envpath(cmd_name: str) -> Optional[str]:
    proc = subprocess.run(['where', cmd_name], capture_output=True)
    return proc.stdout.decode('ascii').strip() if proc.returncode == 0 else None


def listdir_fullpath(dir_name: str) -> List[str]:
    return [os.path.join(dir_name, file) for file in os.listdir(dir_name)] if os.path.isdir(dir_name) else []


def filter_basename(paths: List[str], expected_basename: str) -> List[str]:
    return [path for path in paths if os.path.basename(path).lower().find(expected_basename.lower()) != -1]


def flat_list(list_of_lists: List[List[Any]]) -> List[Any]:
    return [item for sublist in list_of_lists for item in sublist]


def find_cmd_in_program_files(cmd_name) -> Optional[str]:
    program_files_dirs = ['C:\\Program Files', 'C:\\Program Files (x86)']
    all_app_dirs = flat_list(listdir_fullpath(path)
                             for path in program_files_dirs)
    wanted_app_dirs = filter_basename(all_app_dirs, cmd_name)
    wanted_app_files = flat_list(listdir_fullpath(path)
                                 for path in wanted_app_dirs)
    wanted_executables = [file for file in filter_basename(
        wanted_app_files, 'DOSBox') if file.lower().endswith('.exe')]
    return wanted_executables[0] if wanted_executables else None


def find_dosbox_executable() -> Optional[str]:
    return find_cmd_in_envpath('dosbox') or find_cmd_in_program_files('dosbox')


script_dir = os.path.dirname(os.path.abspath(__file__))
cmd_args = ' '.join(sys.argv[1:])
bin_dir = os.path.join(script_dir, 'build')
bin_name = 'output.exe'
bin_path = os.path.join(bin_dir, bin_name)

if not os.path.exists(bin_path):
    print(f'Error: {os.path.relpath(bin_path)} does not exist',
          file=sys.stderr)
    exit(1)

dosbox_exe = find_dosbox_executable()
if not dosbox_exe:
    print('Error: could not find DOSBox executable', file=sys.stderr)
    exit(1)

subprocess.run(
    [dosbox_exe, '-c', f'mount C "{bin_dir}"', '-c', 'C:', '-c', f'{bin_name} {cmd_args}'])
