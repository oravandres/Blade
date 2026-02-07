# Blade macOS Bootstrap (Ansible)

This repo bootstraps Blade as a macOS development machine.

No k3s join logic is included.

## What it configures

- Homebrew installation (if missing)
- Homebrew formulae from `group_vars/macbook.yml`
- Optional Homebrew casks from `group_vars/macbook.yml`

## Files

- `ansible.cfg`
- `inventory/macos.yml`
- `group_vars/macbook.yml`
- `playbooks/bootstrap-macos.yml`
- `roles/blade_macos`

## Run

```bash
ansible-playbook playbooks/bootstrap-macos.yml
```

## Customize packages

Edit `group_vars/macbook.yml`:

- `blade_brew_formulae`
- `blade_brew_casks`
