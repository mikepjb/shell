#!/bin/sh
# Using llama.cpp + Unsloth's Qwen3 (to fix tool calling)

llama-server \
    -m ~/models/Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.gguf \
    --jinja \
    --host 0.0.0.0 \
    --port 9090 \
    -ngl 99 \
    -c 32768 \
    --temp 0.7 --top-p 0.8 --top-k 20 --repeat-penalty 1.05
