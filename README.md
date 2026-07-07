# Custom Ubuntu ISO Customization Toolkit

This toolkit provides an automated structure for building a customized Ubuntu Desktop ISO. It is optimized to run inside the **Cubic** (Custom Ubuntu ISO Creator) chroot terminal environment. It handles package installation, user account configurations, and post-installation validation checks.

---

## Features

- **Desktop Environment & Terminals**: Retains GNOME's default system terminal (**Ptyxis**) without installing extra terminals.
- **Pre-Clean Actions**: Uninstalls conflict default packages (e.g. `vim-tiny` and legacy `gedit`) while retaining default tools like `nano`, `mousepad`, and `ptyxis`.
- **Custom Accounts**: Automatically creates two custom users:
  - **`admin`**: Sudoer account with administrative rights.
  - **`mock`**: Standard system user.
- **Languages**: 
  - OpenJDK **21.0.4** (custom downloaded tarball installation).
  - `gcc`, `g++`, `python3` (with `venv`, `pip`, and `dev` tools), `pypy3`.
- **Editors**: `vi`/`vim`, `gvim`, **GNOME Text Editor** (`gnome-text-editor`), `geany`, `kate`, and latest **Sublime Text** (via official repository).
- **IDEs**:
  - **Code::Blocks** (configured with customized default settings, drag-scroll plugin, and syntax highlights).
  - **VS Code** (configured to disable GitHub Copilot extensions and telemetry by default).
  - **IntelliJ IDEA Community Edition** and **PyCharm Community Edition** (preloaded latest versions).
- **Browsers**: Google Chrome (deb installation), and Firefox (preinstalled as default ubuntu browser).
- **Remote Control & Management**: OpenSSH server/client, Git version control, and Curl.
- **Editor Automations**:
  - Vim configured to automatically save, compile, and run C, C++, Python, and Java files using the `<F5>` shortcut.

---

## Directory Structure

```
Custom ISO/
├── README.md                      # This documentation guide
├── variables.sh                   # Global passwords, accounts, and download URLs
├── setup_users.sh                 # Copies configs to /etc/skel and creates admin/mock accounts
├── install_all.sh                 # Runs individual packages install scripts in logical order
├── afterinstall.sh                # Verifies all package binaries and prints installation summary
├── run_in_cubic.sh                # Cubic main execution orchestrator
├── packages/                      # Individual package install scripts
│   ├── uninstall_defaults.sh      # Purges default editor/terminal conflict tools
│   ├── vim.sh                     # Vim and GVim
│   ├── geany.sh                   # Geany
│   ├── kate.sh                    # Kate
│   ├── sublime.sh                 # Sublime Text latest stable
│   ├── java.sh                    # OpenJDK 21.0.4 setup
│   ├── gcc_gpp.sh                 # Compiler toolchains
│   ├── python.sh                  # Python3 packages
│   ├── pypy3.sh                   # PyPy3 execution environment
│   ├── intellij.sh                # IntelliJ Community Edition
│   ├── pycharm.sh                 # PyCharm Community Edition
│   ├── codeblocks.sh              # Code::Blocks
│   ├── vscode.sh                  # Visual Studio Code
│   ├── browsers.sh                # Google Chrome
│   ├── ssh.sh                     # SSH client/server
│   ├── git.sh                     # Git
│   └── curl.sh                    # Curl
└── config/                        # restructued config directory mirroring standard home layout
    ├── .config/                   # Hidden standard user config directory
    │   ├── codeblocks/            # Code::Blocks default.conf, DragScroll.ini, keybinder, etc.
    │   ├── Code/                  # VS Code custom user settings.json
    │   └── sublime-text/          # Sublime Text custom Preferences.sublime-settings
    └── .vimrc                     # Vim shortcut keys (<F5> compiler runner)
```

---

## Getting Started (Cubic Customization Guide)

### 1. Configure Options
Open `variables.sh` to edit credentials and version settings:
- Update `ADMIN_USER`, `ADMIN_PASS`
- Update `MOCK_USER`, `MOCK_PASS`

### 2. Prepare Base ISO
Ensure you have downloaded an official Ubuntu Desktop ISO file (e.g. `ubuntu-26.04-desktop-amd64.iso`).

### 3. Build the Customized ISO using Cubic

1. Install Cubic on your host machine:
   - On Ubuntu/Debian:
     ```bash
     sudo apt-add-repository ppa:cubic-wizard/release
     sudo apt update
     sudo apt install cubic
     ```
2. Open Cubic and select a workspace directory for your project.
3. Select your base Ubuntu Desktop ISO.
4. When Cubic mounts the ISO and opens the **Chroot Terminal**, drag and drop this entire toolkit folder into the terminal (or use the file copy icon at the top-left to copy it).
5. In the Cubic chroot terminal, navigate to the copied folder:
   ```bash
   cd /path/to/copied/folder
   ```
6. Run the automation helper script:
   ```bash
   bash run_in_cubic.sh
   ```
7. Once finished, click **Next** in Cubic, verify settings, and let Cubic rebuild the bootable ISO.

---

### How the Build Process Works
1. `run_in_cubic.sh` coordinates three main phases:
   - `install_all.sh`: Installs all package libraries, editors, compilers, and IDEs.
   - `setup_users.sh`: Copies the mirrored config layouts from `config/` recursively to `/etc/skel/`. It then creates the custom `admin` and `mock` users using `useradd -m`. Because `useradd` automatically copies `/etc/skel` to the home directories, both users receive their customized config environments seamlessly.
   - `afterinstall.sh`: Performs verification checks for all installed binaries to ensure the system is built correctly.
