# Local AI Models for Shell Tools

This document describes how to set up local AI models with opencode for this repository.

## Quick Setup

### 1. Download the Model

```bash
huggingface-cli download bartowski/Qwen2.5-Coder-3B-GGUF \
  --include "Qwen2.5-Coder-3B-Q4_K_M.gguf" \
  --local-dir ~/models/
```

### 2. Start the Model Server

```bash
llama-server -m ~/models/Qwen2.5-Coder-3B-Q4_K_M.gguf --port 8080
```

### 3. Configure opencode

Create `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "disabled_providers": [
    "openai",
    "anthropic",
    "google",
    "groq",
    "azure",
    "openrouter"
  ],
  "model": "llama/qwen2.5-coder-3b",
  "provider": {
    "llama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://localhost:8080/v1",
        "apiKey": "none"
      },
      "models": {
        "qwen2.5-coder-3b": {
          "id": "qwen2.5-coder-3b"
        }
      }
    }
  }
}
```

## Hardware Requirements

This setup is optimized for:
- Intel i7-8565U (or similar mid-range CPUs)
- 16GB RAM
- No GPU required

**Expected performance:** 5-8 tokens/sec for code generation

## Why Qwen2.5-Coder-3B?

- **5.5 trillion tokens** of code-focused pretraining
- **92 programming languages** support
- **Repo-level understanding** (not just single files)
- **Superior coding benchmarks** vs general-purpose models:
  - HumanEval: 52.4% (vs 31.7% for StarCoder2-3B)
  - BigCodeBench: 72.2%
  - MultiPL-E (8 languages): 48.0%

## Model Specifications

- **File:** Qwen2.5-Coder-3B-Q4_K_M.gguf
- **Size:** ~1.93GB
- **Quantization:** Q4_K_M (4-bit, recommended for CPU)
- **Context window:** 32K tokens
- **RAM usage:** ~4-6GB during inference

## Alternative Models

### For Agentic Tasks (Tool Calling, Note Organization)

| Model | Size | Best For | Download |
|-------|------|----------|----------|
| **Llama 3.2 3B Instruct** | ~2GB | General agents, note summarization, Q&A | `bartowski/Llama-3.2-3B-Instruct-GGUF` |
| **Gemma 2 2B IT** | ~1.5GB | Fastest inference, lightweight tasks | `bartowski/gemma-2-2b-it-GGUF` |
| **Hermes 3 (Llama 3.1 3B)** | ~2GB | Specialized tool calling, agentic behavior | `NousResearch/Hermes-3-Llama-3.1-3B-GGUF` |

### For Code (Lightweight Options)

| Model | Size | Best For | Download |
|-------|------|----------|----------|
| **DeepSeek-Coder 1.3B** | ~0.8GB | Blazing fast autocomplete, code completion | `TheBloke/deepseek-coder-1.3b-base-GGUF` |
| **Stable Code 3B** | ~2GB | 500+ language support, fill-in-the-middle | `TheBloke/stable-code-3b-GGUF` |
| **Qwen2.5-Coder-1.5B** | ~1GB | Constrained hardware, decent code | `bartowski/Qwen2.5-Coder-1.5B-GGUF` |

### Quick Downloads

```bash
# Llama 3.2 3B - Great for note organization & general tasks
huggingface-cli download bartowski/Llama-3.2-3B-Instruct-GGUF \
  --include "Llama-3.2-3B-Instruct-Q4_K_M.gguf" --local-dir ~/models/

# Gemma 2 2B - Fastest option for simple tasks
huggingface-cli download bartowski/gemma-2-2b-it-GGUF \
  --include "gemma-2-2b-it-Q4_K_M.gguf" --local-dir ~/models/

# DeepSeek-Coder 1.3B - Tiny but mighty for code
huggingface-cli download TheBloke/deepseek-coder-1.3b-base-GGUF \
  --include "deepseek-coder-1.3b-base.Q4_K_M.gguf" --local-dir ~/models/

# Stable Code 3B - Specialized code completion
huggingface-cli download TheBloke/stable-code-3b-GGUF \
  --include "stable-code-3b.Q4_K_M.gguf" --local-dir ~/models/
```

## llama.cpp vs Ollama Performance

**For your i7, use llama.cpp directly.** Here's why:

| Factor | llama.cpp | Ollama |
|--------|-----------|--------|
| **Speed** | Faster (direct, no overhead) | Slightly slower (container overhead) |
| **Memory** | Lower footprint | Higher (runs daemon + containers) |
| **Control** | Full control over threads, ctx, etc | Limited options |
| **Convenience** | Manual setup | One-command install |
| **Model management** | Manual downloads | `ollama pull` easy |

**Performance difference on i7:**
- llama.cpp: ~5-8 tokens/sec (3B models)
- Ollama: ~4-6 tokens/sec (same models)
- DeepSeek 1.3B on llama.cpp: ~15-20 tokens/sec

**Recommendation:**
- Use **llama.cpp** for daily work with opencode (better performance)
- Use **Ollama** only if you want to quickly test models without managing GGUF files

## Troubleshooting

**Slow generation?**
- Ensure you're using K-quants (Q4_K_M) not I-quants for CPU inference
- Close other memory-heavy applications
- Try a smaller model (1.5B variant)

**Out of memory?**
- Use smaller context window: `--ctx-size 4096`
- Try Q3_K_M quantization instead

**Tool calling not working?**
- Verify llama-server is running with `--port 8080`
- Check that opencode config has `tools.enabled: true`
- Qwen2.5 has native tool calling support
