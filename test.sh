#!/bin/sh

# -ngl 99 # means to use GPU
# --jinja \ # adds overhead, only if needed for tool calls
# 4096 || 8192 for 3B models
# 16384

# 3B just proved too much..
# llama-server \
#     -m ~/models/Qwen2.5-Coder-3B-Q4_K_M.gguf \
#     -c 16384 \
#     -t 6 \
#     --port 9090 \
#     --temp 0.7 --top-p 0.8 --top-k 20 --repeat-penalty 1.05

# llama-server -m ~/models/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf --port 9090 -c 16384 -t 4
# llama-server -m ~/models/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf --port 9090 -c 4096 -t 2
# llama-server -m ~/models/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf --port 9090 -c 8192 -t 2

# # working debug
# llama-server \
#     -m ~/models/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf \
#     --port 9090 \
#     -c 4096 \
#     -t 2 \
#     --verbose 2>&1 | grep -E "(prompt|task\.n_tokens|message)" | tee llama.log

llama-server \
    -m ~/models/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf \
    --port 9090 \
    -c 8192 \
    -t 6 \
    --verbose 2>&1 | grep -E "(prompt|task\.n_tokens|message)" | tee llama.log
