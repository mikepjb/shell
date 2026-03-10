#!/usr/bin/env bash

export HOST="127.0.0.1"
export PORT="7777"
export CTX="65536"
# export CTX="32768"
# export CTX="131072"

# ulimit -l unlimited # for mlock

llama-server \
  -m "$HOME/models/Qwen3.5-9B-UD-Q3_K_XL.gguf" \
  -c 65536 -ngl -1 \
  --jinja --host "$HOST" --port "$PORT" -c "$CTX" --metrics

  # --threads 10 \
  # --flash-attn on \
  # --mlock \

  # -ub 256 \
  # --n-gpu-layers 35 \
  # -m "$HOME/models/Qwen_Qwen3.5-27B-Q4_K_M.gguf" \
  # --threads 6 \
  # -m "/Users/mike.bruce/models/Qwen_Qwen3.5-35B-A3B-Q4_K_M.gguf" \
  # -m "$HOME/models/Qwen_Qwen3.5-27B-Q4_K_M.gguf" \
  # -ngl "$NGL" \
  # -np "$NPARALLEL" \
  # -ctk "$CTK" -ctv "$CTV" \
  # --threads "$THREADS" \
  # --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" --min-p "$MIN_P" --repeat-penalty "$RP"
