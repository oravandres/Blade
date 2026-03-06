# Blade macOS Bootstrap (Ansible)

This repo bootstraps Blade as a macOS development machine.

## What it configures

- Homebrew installation (if missing)
- Core Homebrew formulae plus host-specific additions from `group_vars/macbook.yml`
- Optional Homebrew casks
- **Ollama** with external model storage and pre-pulled models
- Optional **ComfyUI** checkout, Python environment, GGUF node, and model downloads

## Files

- `ansible.cfg`
- `inventory/macos.yml`
- `group_vars/macbook.yml`
- `playbooks/bootstrap-macos.yml`
- `roles/blade_macos` – Homebrew packages
- `roles/ollama` – Local LLM setup
- `roles/comfyui` – Optional ComfyUI bootstrap
- `scripts/test-ollama.sh` – Ollama smoke test
- `scripts/test-comfyui.sh` – ComfyUI smoke test

## Run

```bash
ansible-playbook playbooks/bootstrap-macos.yml
```

## Customize host settings

Edit `group_vars/macbook.yml`:

- `blade_brew_formulae_extra`
- `blade_brew_casks`
- `blade_comfyui_enabled`
- `blade_comfyui_download_models`
- `blade_ollama_models`
- `blade_ollama_models_dir`

Role defaults live under `roles/*/defaults/main.yml` if you want to change repo-wide defaults.

## Ollama defaults

Example:

```yaml
blade_ollama_models:
  - "deepseek-r1:70b"
  - "qwen3.5:35b"

blade_ollama_models_dir: "/Volumes/Data/ollama/models"
```

Models are stored on the external SSD (`/Volumes/Data`) by default to keep the internal disk clean. Change `blade_ollama_models_dir` to any path you prefer.

Smaller variants are available if you need faster inference.

## ComfyUI notes

ComfyUI is disabled by default at the role level and enabled for Blade in `group_vars/macbook.yml`. Model downloads are large, so keep `blade_comfyui_download_models` disabled on machines that only need the code checkout and virtual environment.

Models are placed under `/Volumes/Data/comfyui/models` by default.

## Smoke tests

After the playbook runs, verify the local AI stack with:

```bash
./scripts/test-ollama.sh
./scripts/test-comfyui.sh "A cinematic product photo of a red keyboard"
```

The Ollama API is available at `http://localhost:11434`.

## Validation

```bash
ansible-playbook --syntax-check playbooks/bootstrap-macos.yml
ansible-lint
```
