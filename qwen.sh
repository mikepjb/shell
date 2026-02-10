#!/bin/sh
# Using llama.cpp + Unsloth's Qwen3 (to fix tool calling), download it here
# with hugging face cli:
# hf download unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.gguf --local-dir ~/models

llama-server \
    -m ~/models/Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.gguf \
    --jinja \
    --host 0.0.0.0 \
    --port 9090 \
    -ngl 99 \
    # -c 32768 \ # 32k context, hit file limits
    -c 65536 \ # 64k context, seems to run well though to use
    --temp 0.7 --top-p 0.8 --top-k 20 --repeat-penalty 1.05
