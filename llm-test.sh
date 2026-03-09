#!/usr/bin/env bash

export HOST="127.0.0.1"
export PORT="7777"
export CTX="8192"
# export CTX="32768"
# export CTX="131072"

llama-server \
  -m "/Users/mike.bruce/models/Qwen3.5-27B-UD-Q3_K_XL.gguf" \
  --n-gpu-layers 35 \
  --threads 10 \
  --flash-attn on \
  --mlock \
  --jinja --host "$HOST" --port "$PORT" -c "$CTX" --metrics

  # -m "$HOME/models/Qwen_Qwen3.5-27B-Q4_K_M.gguf" \
  # --threads 6 \
  # -m "/Users/mike.bruce/models/Qwen_Qwen3.5-35B-A3B-Q4_K_M.gguf" \
  # -m "$HOME/models/Qwen_Qwen3.5-27B-Q4_K_M.gguf" \
  # -ngl "$NGL" \
  # -np "$NPARALLEL" \
  # -ctk "$CTK" -ctv "$CTV" \
  # --threads "$THREADS" \
  # --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" --min-p "$MIN_P" --repeat-penalty "$RP"
