# #!/bin/sh
#
# Start a local OpenAI-compatible server with a web UI:

# use this if on mac -ngl 99
# -c 65536 \
# -c 16384 \

llama-server -m \
    ~/models/unsloth_Qwen3-4B-Instruct-2507-GGUF_Qwen3-4B-Instruct-2507-Q4_K_M.gguf \
    -ngl 99 \
    -c 32768 \
    --port 9091 \
    --temp 0.7 --top-p 0.8 --top-k 20 --repeat-penalty 1.05


# hf download unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.gguf --local-dir ~/models
