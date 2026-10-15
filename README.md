# :trident: Shell

_A collection of tools I use for development work._

- These tools should be lightweight, my work focus is on
  developing software that solves problems.
- This setup was created with a spartan mindset driving it.
  Constraints enforce deeper engagement.
- To get started, download this repo and run `./bin/reload`. This supports Mac OS
  and Arch Linux. This symlinks all the bin/config files so you can run
  `reload` in future.

# LLM usage

- Primarily Local LLMs are used for their speed to help a human programmer get
  unstuck, providing useful analysis & feedback via the `./bin/consult` script.
- For agentic work, `pi` harness with Sol/GLM 5.3/Kimi K3 with minimal AGENTS.md
  direction (post mid-2026 less is more it seems)

# Languages supported

1. Go
2. Javascript/Typescript
3. Python
4. Bash (yes bash is considered a first-class language)
5. Java
6. Zig

## Offline Documentation

### Golang

- `go list std` - lists all stdlib packages
- `go list -m all` - lists all modules in a project
- `go doc x` - list all methods for `x` package
- `go doc -all x` - list all methods with documentation for `x` package

### Python

- `python -m pydoc` or `pydoc`
- `pydoc modules` shows all modules
- `pydoc x` shows docs for that specific module

# Ctags

A tool used to index projects and make it easier to navigate. Like Vim, the more I understand this tool, the better leverage I'm going to get out of it.

Mainly used to enable jumping to code you are using, instead of autocomplete it is expected that I will read the module/class source I want to use. More time initially as a trade for better understanding.

So running `ctags -R .` without config on a node project is going to get me a tags file that I can use.. but it will index `node_modules` LOL and that isn't necessarily what I want.

You can use `:tags /search_term` to search your tags file inside vim.

# Navigation

- `:grep` will grep and populate the results in a quickfix list. Remember to use `%` for the current file and `-r` and `.` if you want to do a project wide search.

- `:grep` inside vim is super useful, i.e `:grep TODO %` to list and move between all TODOs in the current file.

- `tv` runs tree and less together to give a view of the current project
  filesystem.
- `C-;` in Vim opens and toggles Netrw for a similar filesystem view but this
  isn't fully expanded. Still it's good to navigate smaller areas.

## Deeper Detail & Reasoning

### Avoid multiplexing

- Tmux is an excellent tool but should be used sparingly, we highlight it with a
  red status bar to denote it being a danger zone.
- It's great for running multiple processes, ocassionally it's needed when
  running multiple processes (think multiple microservices).

### Editors

- Despite Emacs offering many alluring reasons to choose it (mainly org-mode
  being the killer application), Vim is the choice I keep coming back to:
  - Very portable (available everywhere) and very compatible (no meta/special
    keys that sometimes do not work with terminal emulators).
  - The most important thing here is relying on tools that don't break.

### Why no tmux?

tmux is great but overkill and leads spiralling complexity.

[experiment] bringing back tmux but not by default, this is so I can run agents
in the background and do multitasking which in principal I am against as focused
work in theory should be the most effective approach.

Plan here is to keep to just a single window (bg services can still be used with
PM) - if we going to multitask let's be honest and keep it all in the front view

### Vim syntax not working? Typescript slow?

I recently removed some old lines that I am not sure are needed anymore:

```
autocmd BufEnter * :syntax sync fromstart " syntax highlights from the beginning
of the file, sometimes syntax would be broken without it.
set re=2 " forces newer NFA syntax engine
```
