# Custom Ubuntu ISO Customization Toolkit

This toolkit provides an automated structure for building a customized Ubuntu Desktop ISO. It handles dependencies, package management, user configurations, desktop environment setup, editor customization, post-installation validation, and user creation.

---

## Features

- **Desktop Environment**: GNOME desktop environment with default configurations.
- **Pre-Clean Actions**: Uninstalls conflict default packages, default text editors, and default terminal configuration commands.
- **Custom Accounts**: Automatically creates two custom users:
  - **`admin`**: Sudoer account with administrative rights.
  - **`mock`**: Standard system user.
- **Languages**: 
  - OpenJDK **21.0.4** (custom downloaded tarball installation).
  - `gcc`, `g++`, `python3` (with `venv`, `pip`, and `dev` tools), `pypy3`.
- **Editors**: `vi`/`vim`, `gvim`, `emacs`, `gedit`, `geany`, `kate`, and latest **Sublime Text** (via official repository).
- **IDEs**:
  - **Code::Blocks** (configured to launch code execution in the system's default terminal instead of xterm).
  - **VS Code** (configured to disable GitHub Copilot extensions and telemetry by default).
  - **IntelliJ IDEA Community Edition** and **PyCharm Community Edition** (preloaded latest versions).
- **Browsers**: Google Chrome (deb installation).
- **Remote Control & Management**: OpenSSH server/client, Git version control, and Curl.
- **Editor Automations**:
  - Vim & Emacs configured to automatically save, compile, and run C, C++, Python, and Java files using the `<F5>` shortcut.

---

## Directory Structure

```
Custom ISO/
├── README.md                      # This documentation guide
├── variables.sh                   # Global passwords, accounts, and download URLs
├── setup_users.sh                 # Configures user creation and group definitions
├── install_all.sh                 # Runs individual packages install scripts in logical order
├── afterinstall.sh                # Verifies all package binaries, reinstalls if missing, copies configs
├── build_iso.sh                   # Main build pipeline orchestrator (mounts, chroots, and packages ISO)
├── packages/                      # Individual package install scripts
│   ├── uninstall_defaults.sh      # Purges default editor/terminal tools
│   ├── desktop.sh                 # GNOME desktop and gnome-terminal setup
│   ├── vim.sh                     # Vim and GVim
│   ├── emacs.sh                   # Emacs
│   ├── gedit.sh                   # Gedit
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
└── config/                        # Shared custom settings templates
    ├── codeblocks/                # Configures default terminal instead of xterm
    ├── vscode/                    # Disables Copilot and telemetry
    ├── sublime/                   # UI Preferences & update checks disabled
    ├── vim/                       # Shortcut keys (<F5> compiler runner)
    └── emacs/                     # Emacs configuration setup
```

---

## Getting Started

### 1. Configure Options
Open `variables.sh` to edit credentials and details:
- Update `ADMIN_USER`, `ADMIN_PASS`
- Update `MOCK_USER`, `MOCK_PASS`
- Adjust links or version arguments if required.

### 2. Prepare Base ISO
Ensure you have downloaded an official Ubuntu Desktop ISO file (e.g. `ubuntu-26.04-desktop-amd64.iso`).

### 3. Build the Customized ISO

#### Option A: Customizing via Cubic (Recommended)
Modern Ubuntu LTS releases use a new layered SquashFS architecture (`minimal.standard.live.squashfs`, `minimal.squashfs`, etc.) instead of a single flat `filesystem.squashfs`. **Cubic** (Custom Ubuntu ISO Creator) natively supports these new layers.

1. Install Cubic on your host machine:
   - On Ubuntu/Debian:
     ```bash
     sudo apt-add-repository ppa:cubic-wizard/release
     sudo apt update
     sudo apt install cubic
     ```
2. Open Cubic and select a workspace directory for your project.
3. Select your base Ubuntu Desktop ISO.
4. When Cubic mounts the ISO and opens the **Chroot Terminal**, drag and drop this entire toolkit folder (`Custom ISO`) into the terminal, or use the file copy icon at the top-left to copy it.
5. In the Cubic chroot terminal, navigate to the copied folder:
   ```bash
   cd /path/to/copied/Custom\ ISO
   ```
6. Run the automation helper script:
   ```bash
   bash run_in_cubic.sh
   ```
7. Once finished, click **Next** in Cubic, verify settings, and let Cubic rebuild the bootable ISO.

#### Option B: Using the CLI build_iso.sh Script
*Note: The CLI script mounts and unpacks standard flat-rootfs layouts. It is provided for legacy and automated environment compatibilities.*
```bash
sudo ./build_iso.sh --base-iso /path/to/ubuntu-26.04-desktop-amd64.iso --output-iso /path/to/custom-ubuntu.iso
```


### How the Build Process Works
1. Installs host utilities (`squashfs-tools`, `xorriso`, `rsync`).
2. Mounts the base ISO and extracts its contents.
3. Unpacks the `filesystem.squashfs` containing the root system.
4. Mounts host virtual filesystems (`/dev`, `/sys`, `/proc`) into the rootfs and copies this configuration toolkit inside.
5. enters a `chroot` environment inside the rootfs and runs:
   - `install_all.sh`: Installs all defined packages.
   - `setup_users.sh`: Creates user accounts and directories.
   - `afterinstall.sh`: Verifies packages, resolves any failures, and applies configuration templates to `/etc/skel` and user directories.
6. Repackages the modified rootfs back into `filesystem.squashfs`.
7. Regenerates the bootable ISO using the correct BIOS and UEFI GRUB configurations.

---

## Vim Custom Configuration

The customized `.vimrc` configuration file is automatically applied to both users' home directories (`admin` and `mock`) and the system skeleton (`/etc/skel`). It features:

```vim
" --- Filetype & Syntax Core ---
filetype plugin indent on   " Enable filetype detection, filetype plugins, and indents
syntax on                   " Enable syntax highlighting

" --- Tab, Indentation & Formatting ---
set tabstop=2               " ts: Render tabs as 2 spaces
set softtabstop=2           " Number of spaces a TAB counts for while editing
set shiftwidth=2            " sw: Formatting/Indentation step size is 2 spaces
set expandtab               " Force Vim to use spaces instead of literal tab characters
set autoindent              " ai: Copy indentation from previous line on newline
set smartindent             " Smart auto-indenting for code blocks

" --- Interface & Behavior Settings ---
set number                  " nu: Show line numbers
set ruler                   " ru: Show cursor position (row, col) in status line
set laststatus=2            " ls=2: Always show the status line
set showmode                " smd: Show current mode (INSERT, VISUAL, etc.)
set showcmd                 " sc: Show incomplete commands in status bar
set scrolloff=3             " so=3: Keep 3 lines visible above/below cursor when scrolling
set mouse=a                 " mouse=a: Enable full mouse support in all modes
set backspace=2             " bs=2: Allow backspacing over everything (indent, eol, start)
set linebreak               " lbr: Wrap long lines at clean visual boundaries (words)
set nocompatible            " nocp: Use modern Vim behaviors over ancient Vi defaults

" --- Search Settings ---
set hlsearch                " hls: Highlight all search matches
set incsearch               " is: Highlight search matches on the fly while typing
set ignorecase              " ic: Ignore case when searching...
set smartcase               " scs: ...unless search query contains uppercase letters

" --- Run code directly from vim with F5 key ---
autocmd FileType python nnoremap <F5> :w<CR>:!python3 %<CR>
autocmd FileType cpp nnoremap <F5> :w<CR>:!g++ -O2 -Wall % -o %:r && ./%:r<CR>
autocmd FileType c nnoremap <F5> :w<CR>:!gcc -O2 -Wall % -o %:r && ./%:r<CR>
autocmd FileType java nnoremap <F5> :w<CR>:!javac % && java %:r<CR>
```

