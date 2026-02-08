# Local AI Setup: OpenCode + Ollama

Running Claude Code alternatives locally on your machine for offline work and model flexibility.

## Quick Start (One-Liner)

**Works on both macOS and Linux:**
```bash
curl -fsSL https://opencode.ai/install | bash
opencode
```

## Installation Options

### Universal One-Liner (Recommended)
```bash
curl -fsSL https://opencode.ai/install | bash
```

Works on macOS and Linux. Automatically detects your OS and architecture.

### Via npm (Alternative)
```bash
npm install -g opencode-ai@latest
```

Requires Node.js installed.

## Ollama Setup (Local LLM Runtime)

### Installation

**macOS - Homebrew:**
```bash
brew install ollama
```

**macOS - Direct Download:**
- Visit https://ollama.ai
- Download the macOS installer
- Run and follow setup

**Linux - Official Installation:**
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**Linux - Using Package Manager:**
```bash
# Ubuntu/Debian
sudo apt-get install ollama

# Arch
sudo pacman -S ollama
```

**Check if already installed:**
```bash
ollama --version
```

### Running Ollama

Start the Ollama service:
```bash
ollama serve
```

This runs as a background service and exposes a local API on `http://localhost:11434`

### Pulling Models

Models are downloaded on-demand. Popular choices:

**For coding (recommended):**
```bash
ollama pull qwen2.5-coder:7b    # Best for coding, ~4GB
```

**Balanced option:**
```bash
ollama pull mistral-small       # Fast, good quality, ~6GB
```

**Other options:**
```bash
ollama pull llama2              # General purpose, fast
ollama pull deepseek-coder      # Coding specialist
```

Check available models: https://ollama.ai/library

### Model File Locations

Models are stored in:
- **macOS**: `~/.ollama/models/`

To see what you've downloaded:
```bash
ollama list
```

## Configuring OpenCode with Ollama

### 1. Start Ollama (if not already running)

In a separate terminal:
```bash
ollama serve
```

### 2. Configure OpenCode to use Ollama

Run OpenCode and configure during setup:
```bash
opencode
```

At the prompt, configure Ollama as your provider. When asked for the API endpoint:
```
http://localhost:11434
```

Alternatively, set environment variable:
```bash
export OPENCODE_PROVIDER=ollama
export OPENCODE_OLLAMA_URL=http://localhost:11434
```

### 3. Select your model in OpenCode

When you run `opencode`, it will let you pick which model to use (the ones you've downloaded with `ollama pull`).

## Workflow Example

### Terminal 1: Run Ollama service
```bash
ollama serve
```

### Terminal 2: Use OpenCode
```bash
# Launch OpenCode TUI
opencode

# Or use non-interactive mode
opencode "write a function that validates email addresses"
```

OpenCode will:
- Scan your git repository
- Understand your codebase
- Make edits directly to files
- Run terminal commands
- All using your local Ollama model

## Model Selection Guide

### For Coding Tasks (Recommended)
- **Qwen 2.5 Coder 7B** - Best code generation, beats GPT-4o on benchmarks
- **DeepSeek Coder 6.7B** - Purpose-built for programming
- **Mistral Small 24B** - Larger, better reasoning

### For General Tasks
- **Mistral Small 24B** - Balanced, fast, high quality
- **Llama 3.2** - Great all-rounder

### For Speed (Low VRAM)
- **Qwen 2.5 Coder 7B** - Recommended starting point
- **Llama 3.2 1B** - Ultra-lightweight but less capable

## Hardware Requirements

**Minimum:**
- 8GB unified memory (M1/M2/M3 minimum)
- For 7B models with quantization

**Recommended:**
- 16GB+ unified memory (M3 Pro/Max or later)
- For comfortable use with larger models

**Your machine** (Apple Silicon T6031):
- Should handle 7B-24B models comfortably
- Start with Qwen 2.5 Coder 7B and upgrade if needed

## Troubleshooting

### Ollama won't start
```bash
# Check if service is running
pgrep ollama

# Check logs
ollama logs

# Restart
killall ollama
ollama serve
```

### OpenCode can't find Ollama
```bash
# Ensure Ollama service is running in another terminal
ollama serve

# Check if API is accessible
curl http://localhost:11434/api/tags
```

### Model is too slow
- Try a smaller model: `ollama pull qwen2.5-coder:7b` instead of larger versions
- Close other applications
- Check system resources: `top` or Activity Monitor

### Models are taking disk space
```bash
# See model sizes
ollama list

# Remove unused models
ollama rm model-name
```

## Advanced: Custom Installations

### Upgrade Ollama
```bash
brew upgrade ollama
```

### Use quantized models for efficiency
Ollama automatically handles quantization—models are downloaded in GGUF format, which is pre-optimized for your hardware.

## References

- OpenCode: https://opencode.ai
- Ollama: https://ollama.ai
- Available Models: https://ollama.ai/library
- Model Rankings: https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard

## See Also

- [Comparing Inference Engines](https://www.arsturn.com/blog/vllm-vs-ollama-vs-llama-cpp-production-use)
- [Best Local LLMs for Apple Silicon](https://apxml.com/posts/best-local-llms-apple-silicon-mac)
