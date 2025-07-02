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
