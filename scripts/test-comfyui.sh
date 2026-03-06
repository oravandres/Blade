#!/usr/bin/env bash
set -euo pipefail

# Quick test for ComfyUI + FLUX.2-dev-GGUF image generation
# Usage: ./scripts/test-comfyui.sh [prompt]
#
# Prerequisites: ComfyUI must be running on port 8188
#   cd ~/ComfyUI && ./venv/bin/python main.py

prompt="${1:-A majestic mountain landscape at sunset with golden light}"
comfyui_url="${COMFYUI_URL:-http://127.0.0.1:8188}"
prompt_json="$(python3 -c 'import json, sys; print(json.dumps(sys.argv[1]))' "$prompt")"

printf 'Generating image with FLUX.2-dev-GGUF\n'
printf 'Prompt: %s\n\n' "$prompt"

# Check if ComfyUI is running
if ! curl -fsS "$comfyui_url/system_stats" > /dev/null 2>&1; then
  echo "ComfyUI is not running. Start it first:"
  echo "  cd ~/ComfyUI && ./venv/bin/python main.py"
  exit 1
fi

# Queue a prompt using the FLUX.2 GGUF workflow
workflow=$(cat <<EOF
{
  "prompt": {
    "1": {
      "class_type": "UnetLoaderGGUF",
      "inputs": {
        "unet_name": "flux2-dev-Q4_K_M.gguf"
      }
    },
    "3": {
      "class_type": "CLIPLoader",
      "inputs": {
        "clip_name": "mistral_3_small_flux2_fp8.safetensors",
        "type": "flux"
      }
    },
    "4": {
      "class_type": "CLIPTextEncode",
      "inputs": {
        "text": $prompt_json,
        "clip": ["3", 0]
      }
    },
    "5": {
      "class_type": "EmptySD3LatentImage",
      "inputs": {
        "width": 1024,
        "height": 1024,
        "batch_size": 1
      }
    },
    "6": {
      "class_type": "KSampler",
      "inputs": {
        "model": ["1", 0],
        "positive": ["4", 0],
        "negative": ["4", 0],
        "latent_image": ["5", 0],
        "seed": $RANDOM,
        "steps": 20,
        "cfg": 1.0,
        "sampler_name": "euler",
        "scheduler": "simple",
        "denoise": 1.0
      }
    },
    "7": {
      "class_type": "VAEDecode",
      "inputs": {
        "samples": ["6", 0],
        "vae": ["8", 0]
      }
    },
    "8": {
      "class_type": "VAELoader",
      "inputs": {
        "vae_name": "flux2-vae.safetensors"
      }
    },
    "9": {
      "class_type": "SaveImage",
      "inputs": {
        "images": ["7", 0],
        "filename_prefix": "flux2_test"
      }
    }
  }
}
EOF
)

echo "Queuing generation..."
response=$(curl -fsS -X POST "$comfyui_url/prompt" \
  -H "Content-Type: application/json" \
  -d "$workflow")

prompt_id=$(printf '%s' "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt_id',''))" 2>/dev/null)

if [ -z "$prompt_id" ]; then
  echo "Failed to queue prompt. Response:"
  printf '%s\n' "$response" | python3 -m json.tool 2>/dev/null || printf '%s\n' "$response"
  exit 1
fi

printf 'Queued. Prompt ID: %s\n' "$prompt_id"
printf 'Check ComfyUI UI at %s for progress.\n' "$comfyui_url"
echo "Output will be saved in ~/ComfyUI/output/"
