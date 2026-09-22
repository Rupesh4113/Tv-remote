"""
PyInstaller Packaging Script for AI Smart Remote Local Agent
Builds a standalone executable for:
- Windows (.exe)
- macOS (.app / binary)
- Linux (ELF binary)
"""

import sys
import subprocess
from pathlib import Path


def build():
    agent_dir = Path(__file__).resolve().parent
    entry_script = agent_dir / "agent.py"
    project_root = agent_dir.parent

    print(f"Building standalone Local Remote Agent from: {entry_script}")

    cmd = [
        sys.executable,
        "-m", "PyInstaller",
        "--name=ai-smart-remote-agent",
        "--onefile",
        f"--paths={project_root}",
        "--hidden-import=uvicorn.logging",
        "--hidden-import=uvicorn.loops",
        "--hidden-import=uvicorn.loops.auto",
        "--hidden-import=uvicorn.protocols",
        "--hidden-import=uvicorn.protocols.http",
        "--hidden-import=uvicorn.protocols.http.auto",
        "--hidden-import=uvicorn.protocols.websockets",
        "--hidden-import=uvicorn.protocols.websockets.auto",
        "--hidden-import=websockets.legacy.server",
        str(entry_script)
    ]

    print("Running command: " + " ".join(cmd))
    try:
        subprocess.run(cmd, check=True)
        print("\nBuild completed successfully! Binary located in 'dist/' directory.")
    except FileNotFoundError:
        print("PyInstaller not installed. Install via: pip install pyinstaller")
    except subprocess.CalledProcessError as e:
        print(f"Build failed with code {e.returncode}")


if __name__ == "__main__":
    build()
