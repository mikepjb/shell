#!/bin/sh
# LLM server launcher using llama.cpp
# Usage: ./llm.sh [--model <name>]
# UMA set to allocate 4GB for iGPU by default

set -e

CONFIG="$(dirname "$0")/models.yaml"

# Check deps
if ! command -v yq >/dev/null 2>&1; then
  echo "Error: yq not found"
  echo "Install from: https://github.com/mikefarah/yq/releases"
  exit 1
fi

[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG"; exit 1; }

# Parse args
MODEL=""
while [ $# -gt 0 ]; do
  case "$1" in
    --model) MODEL="$2"; shift 2 ;;
    -h|--help) echo "Usage: $0 [--model <name>]"; exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

# If no model specified, show available options
if [ -z "$MODEL" ]; then
  echo "Available models:"
  yq eval '.models | keys | .[]' "$CONFIG" | sed 's/^/  - /'
  echo ""
  echo "Usage: $0 --model <model_name>"
  exit 0
fi

# Validate model
yq eval ".models[\"${MODEL}\"]" "$CONFIG" | grep -q source || {
  echo "Model '$MODEL' not found"
  echo "Available: $(yq eval '.models | keys | .[]' "$CONFIG" | tr '\n' ' ')"
  exit 1
}

echo "Loading: $MODEL"

# Read config with defaults
REPO=$(yq eval ".models[\"${MODEL}\"].source.repo" "$CONFIG")
FILE=$(yq eval ".models[\"${MODEL}\"].source.file" "$CONFIG")
MODEL_PATH="$HOME/models/$FILE"

CTX=$(yq eval ".models[\"${MODEL}\"].context // 32768" "$CONFIG")
TEMP=$(yq eval ".models[\"${MODEL}\"].temp // 0.7" "$CONFIG")
TOP_P=$(yq eval ".models[\"${MODEL}\"][\"top-p\"] // 0.8" "$CONFIG")
TOP_K=$(yq eval ".models[\"${MODEL}\"][\"top-k\"] // 20" "$CONFIG")
RP=$(yq eval ".models[\"${MODEL}\"][\"repeat-penalty\"] // 1.05" "$CONFIG")
PORT=$(yq eval ".models[\"${MODEL}\"].port // 7777" "$CONFIG")
HOST=$(yq eval ".models[\"${MODEL}\"].host // \"127.0.0.1\"" "$CONFIG" | tr -d '"')
MLOCK=$(yq eval ".models[\"${MODEL}\"].mlock // false" "$CONFIG")
NGL=$(yq eval ".models[\"${MODEL}\"][\"gpu-layers\"] // 0" "$CONFIG")
MIN_P=$(yq eval ".models[\"${MODEL}\"][\"min-p\"] // 0.0" "$CONFIG")
NPARALLEL=$(yq eval ".defaults[\"n-parallel\"] // 1" "$CONFIG")
MMAP=$(yq eval ".defaults.mmap // true" "$CONFIG")
CTK=$(yq eval ".defaults[\"ctx-token-key\"] // \"q4_0\"" "$CONFIG")
CTV=$(yq eval ".defaults[\"ctx-token-val\"] // \"q4_0\"" "$CONFIG")
THREADS=$(yq eval ".defaults.threads // 10" "$CONFIG")

# Debug: show config values
echo "Config: n-parallel=$NPARALLEL, mmap=$MMAP, threads=$THREADS"

# Download if needed
if [ ! -f "$MODEL_PATH" ]; then
  [ -n "$REPO" ] || { echo "No source configured for ${MODEL}"; exit 1; }
  echo "Downloading: $REPO/$FILE"
  command -v hf >/dev/null 2>&1 || { echo "Install: pip install huggingface-hub"; exit 1; }
  hf download "$REPO" "$FILE" --local-dir ~/models
fi

# Run server
echo "Starting llama-server on port $PORT..."
llama-server \
  -m "$MODEL_PATH" --jinja --host "$HOST" --port "$PORT" -c "$CTX" --metrics \
  -ngl "$NGL" \
  -np "$NPARALLEL" \
  -ctk "$CTK" -ctv "$CTV" \
  --threads "$THREADS" \
  ${MLOCK:+--mlock} \
  $([ "$MMAP" = "false" ] && echo "--no-mmap") \
  --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" --min-p "$MIN_P" --repeat-penalty "$RP"
