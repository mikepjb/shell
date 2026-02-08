# :trident: Shell

_A collection of tools I use for development work._

- These tools should be lightweight, my work focus is on
  developing software that solves problems.
- This setup was created with a spartan mindset driving it.
  Constraints enforce deeper engagement.
- To get started, download this repo and run `./setup.sh`. This supports Mac OS
  and Arch Linux.

## Development Discipline

- For complex projects, you can't win that fight (small/surgical changes).
- For projects you own (like this one), make it extremely simple.
- Greenfield and replace systems that are important to you (complex -> simple).
- 10k LOC for a service, 20k as an upper bound (limit service complexity).

## Tools you may want to implement

- curl caller (like postman.. stores historical calls)
- same for 
- bash history grep oneliner

## Avoid

- Light mode (you never use it)
- Exceeding 80 character width (becomes harder to read)
- Exceeding 300 lines for source code (small enough to reason about).
- Exceeding 100 lines for config (these have a larger effect).

## On my radar

- Using the `:g/pattern/command` in vim
- Using args/argdo/update to apply updates across a project:
```
:args **/*.{js,ts,jsx,tsx}
:argdo %s/console\.log/logger.debug/g | update
```

---
nvim > vim, why?
- clipboard integration (wayland)
- lua plugins, allows telescope/fuzzy finding without extra external/language dep (e.g
  selecta/fzf)
- config is much cleaner in lua. multistrings etc.
- Alt keybindings!

## Local AI / OpenCode Setup

For offline development or when Claude is down, see [LOCAL_AI_SETUP.md](./LOCAL_AI_SETUP.md) for setting up:
- **OpenCode**: Open-source AI coding agent (Claude Code alternative)
- **Ollama**: Local LLM inference runtime
- **Model selection**: Recommendations for your hardware

Quick start (works on Mac and Linux):
```bash
curl -fsSL https://opencode.ai/install | bash  # Install OpenCode
ollama pull qwen2.5-coder:7b                    # Download a model
opencode                                       # Start working
```

## Java LSP

```
  To use it:
  1. Install jdtls: brew install jdtls
  2. Download lombok: curl -L https://projectlombok.org/downloads/lombok.jar -o ~/.config/nvim/lombok.jar
  3. Add to your init.lua: vim.api.nvim_create_autocmd('FileType', {pattern = 'java', callback = function() dofile(os.getenv('HOME') .. '/src/shell/jdtls.lua') end})
```
