#!/usr/bin/env python3

import os
import subprocess
import sys

script_dir = os.path.dirname(os.path.abspath(__file__))
build_dir = os.path.join(script_dir, 'build')
compiler_path = os.path.join(script_dir, 'compiler', 'ML.exe')
linker_path = os.path.join(script_dir, 'compiler', 'LINK.exe')
source_path = os.path.join(script_dir, 'src', 'main.asm')

if not os.path.exists(build_dir):
    os.mkdir(build_dir)
elif not os.path.isdir(build_dir):
    print(f'Error: {build_dir} is not a directory', file=sys.stderr)
    exit(1)

original_working_dir = os.getcwd()
os.chdir(build_dir)
compiler_process = subprocess.run(
    [compiler_path, '/Bl', linker_path, '/Fe', 'output.exe', source_path])
os.chdir(original_working_dir)

if compiler_process.returncode != 0:
    print(f'Error: compiler retuned status {compiler_process.returncode}', file=sys.stderr)
    exit(compiler_process.returncode)
