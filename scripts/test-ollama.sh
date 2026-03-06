#!/usr/bin/env bash
set -euo pipefail

# Quick test for Ollama models
# Usage: ./scripts/test-ollama.sh [model] [prompt]

model="${1:-qwen3.5:35b}"
prompt="${2:-Explain quantum computing in 3 sentences.}"
models_dir="${OLLAMA_MODELS:-/Volumes/Data/ollama/models}"

printf 'Testing model: %s\n' "$model"
printf 'Prompt: %s\n\n' "$prompt"

OLLAMA_MODELS="$models_dir" ollama run "$model" "$prompt"
