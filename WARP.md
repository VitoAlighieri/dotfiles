# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

This is an Ansible-based dotfiles management system designed for Arch Linux. The repository uses Ansible playbooks and roles to automate the installation and configuration of development tools and system configurations.

## Architecture

### Entry Point Flow
1. `bin/dotfiles` - Bash script that bootstraps the entire setup
   - Installs prerequisites (Ansible, Python, SSH, fonts)
   - Clones/updates the dotfiles repository to `~/.dotfiles`
   - Updates Ansible Galaxy collections
   - Executes the main playbook

2. `main.yml` - Primary Ansible playbook
   - Runs pre-tasks to register the host user
   - Dynamically determines which roles to execute based on tags or `default_roles`
   - Supports `exclude_roles` for selective execution

3. Roles - Modular configuration units in `roles/`
   - Each role follows standard pattern: check distribution → install packages → create config symlinks

### Role Structure Pattern
Every role follows this consistent structure:
```
roles/<tool>/
├── tasks/
│   ├── main.yml          # Entry point - checks for distribution-specific tasks
│   └── Archlinux.yml     # Distribution-specific installation tasks (uses AUR when needed)
├── files/                # Configuration files to be symlinked to ~/.config/<tool>/
└── defaults/             # (Optional) Variable definitions
```

Roles use a two-step process:
1. **Install**: Check for distribution-specific installation file and run it
2. **Configure**: Create `~/.config/<tool>` directory and symlink `files/` directory to it

### Key Files
- `group_vars/all.yml` - Defines `default_roles` list (active roles to run)
- `pre_tasks/register_host.yml` - Sets `host_user` fact from environment
- `requirements/common.yml` - Common Ansible collections (community.general, kubernetes.core)
- `requirements/arch.yml` - Arch-specific collections (kewlfft.aur for AUR support)
- `ansible.cfg` - Enables `bin_ansible_callbacks` for better ad-hoc command output

## Common Commands

### Initial Setup (On Arch Linux)
```bash
# Run the complete dotfiles installation
bash <(curl -s https://raw.githubusercontent.com/VitodAlighieri/dotfiles/main/bin/dotfiles)

# Or locally from the repo
./bin/dotfiles
```

### Running the Playbook

```bash
# Run all default roles
ansible-playbook main.yml

# Run specific role(s) only
ansible-playbook main.yml --tags "neovim,bat"

# Run with vault password file (if using encrypted vars)
ansible-playbook --vault-password-file $VAULT_SECRET main.yml

# Check what would change (dry-run)
ansible-playbook main.yml --check

# Verbose output for debugging
ansible-playbook main.yml -v    # or -vv, -vvv for more verbosity
```

### Testing Individual Roles

```bash
# Test a specific role
ansible localhost -m include_role -a name=neovim

# Check if role files exist
ansible localhost -m stat -a "path=roles/neovim/tasks/main.yml"
```

### Managing Ansible Galaxy Collections

```bash
# Install/update required collections
ansible-galaxy install -r requirements/common.yml
ansible-galaxy install -r requirements/arch.yml    # On Arch Linux

# List installed collections
ansible-galaxy collection list
```

## Development Workflow

### Adding a New Role

1. Create role directory structure:
   ```bash
   mkdir -p roles/<tool>/{tasks,files,defaults}
   ```

2. Create `roles/<tool>/tasks/main.yml` with standard pattern:
   ```yaml
   ---
   - name: "<Tool> | Checking for Distribution Config: {{ ansible_distribution }}"
     ansible.builtin.stat:
       path: "{{ role_path }}/tasks/{{ ansible_distribution }}.yml"
     register: <tool>_distribution_config

   - name: "<Tool> | Run {{ ansible_distribution }} Tasks"
     ansible.builtin.include_tasks: "{{ ansible_distribution }}.yml"
     when: <tool>_distribution_config.stat.exists

   - name: "<Tool> | Configure folder"
     ansible.builtin.file:
       mode: "0755"
       path: "{{ ansible_user_dir }}/.config/<tool>"
       state: directory

   - name: "<Tool> | Create symlink to role files directory"
     ansible.builtin.file:
       src: "{{ role_path }}/files"
       dest: "{{ ansible_user_dir }}/.config/<tool>"
       state: link
       force: true
   ```

3. Create distribution-specific installation (e.g., `roles/<tool>/tasks/Archlinux.yml`):
   ```yaml
   ---
   - name: "<Tool> | Install via pacman"
     become: true
     community.general.pacman:
       name: <package-name>
       state: present

   # Or for AUR packages:
   - name: "<Tool> | Install from AUR"
     kewlfft.aur.aur:
       name: <aur-package-name>
       state: present
   ```

4. Add configuration files to `roles/<tool>/files/`

5. Enable the role by adding it to `default_roles` in `group_vars/all.yml`

### Testing Changes

When making changes to roles or configurations:

1. **Syntax check**: `ansible-playbook main.yml --syntax-check`
2. **Dry run**: `ansible-playbook main.yml --check --diff`
3. **Run specific role**: `ansible-playbook main.yml --tags "<role_name>"`
4. **Verify symlinks**: Check that `~/.config/<tool>` points to the correct location

### Important Variables

- `host_user` - Set during pre-tasks, contains the current user
- `ansible_user_dir` - Home directory of the ansible user
- `role_path` - Absolute path to the current role directory
- `ansible_distribution` - OS distribution name (e.g., "Archlinux")
- `default_roles` - List of roles to run (defined in `group_vars/all.yml`)
- `exclude_roles` - Optional list of roles to skip
- `run_roles` - Computed list (tags-based or default_roles minus excluded)

## Active Roles

Currently enabled in `default_roles`:
- bat - Modern cat replacement with syntax highlighting
- hypr - Hyprland compositor configuration
- lsd - Modern ls replacement
- neovim - Text editor (uses NvChad configuration)
- rofi - Application launcher
- superfile - Modern file manager
- vscode - Visual Studio Code configuration
- waybar - Status bar for Wayland compositors
- yazi - Terminal file manager

Many roles are commented out but available for activation.

## Notes

- The `bin/dotfiles` script is designed for Arch Linux and assumes `pacman` package manager
- First run creates `~/.dotfiles_run` marker file and prompts for reboot
- SSH keys are auto-generated on first run if not present
- All configuration files are symlinked (not copied) to allow easy updates via git pull
- The playbook runs against localhost with local connection (no SSH required)
- Tags can be used to run subsets of roles: `--tags "role1,role2"`
