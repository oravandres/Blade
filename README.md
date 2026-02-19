# Blade macOS Bootstrap (Ansible)

This repo bootstraps Blade as a macOS development machine.

No k3s join logic is included.

## What it configures

- Homebrew installation (if missing)
- Homebrew formulae from `group_vars/macbook.yml`
- Optional Homebrew casks from `group_vars/macbook.yml`
- **Ollama** – local LLM inference engine with pre-pulled models

## Files

- `ansible.cfg`
- `inventory/macos.yml`
- `group_vars/macbook.yml`
- `playbooks/bootstrap-macos.yml`
- `roles/blade_macos` – Homebrew packages
- `roles/ollama` – Local LLM setup

## Run

```bash
ansible-playbook playbooks/bootstrap-macos.yml
```

## Customize packages

Edit `group_vars/macbook.yml`:

- `blade_brew_formulae`
- `blade_brew_casks`

## Customize LLM models

Edit `group_vars/macbook.yml`:

```yaml
blade_ollama_models:
  - "qwen3:8b"
  - "qwen3:1.7b"
  - "deepseek-r1:8b"
  - "deepseek-r1:1.5b"

blade_ollama_models_dir: "/Volumes/Data/ollama/models"
```

Models are stored on the external SSD (`/Volumes/Data`) by default to keep the internal disk clean. Change `blade_ollama_models_dir` to any path you prefer.

Larger variants (14b, 32b, 70b) are available if your Mac has enough RAM.

After the playbook runs, verify with:

```bash
ollama list               # show pulled models
ollama run qwen3:8b       # interactive chat
```

The Ollama API is available at `http://localhost:11434`.
