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

Using LLMs largely divides into two groups:

1. Small/local models (Qwen 3.5 2B/4B/9B or even 27B)
    - Primarily for assisting human development.
    - Helps get unstuck, querying about API usage or debugging using a library.
    - Essentially like a pair programmer
    - Review final code created by human
    - Primary mode of operation, where code quality and system understanding are
      a priority. In my assessments there isn't a huge speed difference when
      factoring in time waiting for fully-agentic workflows, corrections and
      review of larger PRs.
2. Frontier models (Sol High, GLM 5.3, Kimi K3)
    - Fully agentic, with few prompt blocks (i.e restrict to the project but
      allow everything)
    - Very little direction in AGENTS.md (important for mid-2026 frontier)
    - The expectation is to set a goal and have the agent/LLM work towards it.
    - Secondary mode of operation, where you do not care about the code quality
      but on the result. That result also has a pretty wide acceptance criteria.
    - Something like, creating a dashboard.

# Languages supported

_Primarily_

1. Go
2. Javascript/Typescript
3. Java
4. Python
5. Bash (yes bash is considered a first-class language)

_Secondarily_

6. Clojure
7. Ruby
8. Rust

# Ctags

A tool used to index projects and make it easier to navigate. Like Vim, the more I understand this tool, the better leverage I'm going to get out of it.

Mainly used to enable jumping to code you are using, instead of autocomplete it is expected that I will read the module/class source I want to use. More time initially as a trade for better understanding.

So running `ctags -R .` without config on a node project is going to get me a tags file that I can use.. but it will index `node_modules` LOL and that isn't necessarily what I want.

You can use `:tags /search_term` to search your tags file inside vim.

# Navigation

- `:grep` will grep and populate the results in a quickfix list. Remember to use `%` for the current file and `-r` and `.` if you want to do a project wide search.

- `:grep` inside vim is super useful, i.e `:grep TODO %` to list and move between all TODOs in the current file.

## Offline language docs

`doc` exposes local language and package documentation as streamable commands:

```sh
doc list go std | rg 'io|file'
doc members go io/fs | less
doc show go io/fs WalkDir | less
doc search java 'Files\.walk' std | less
```

Use `doc help` for commands and scopes. `list` defaults to the standard
library where available; use `project`, `modules`, `packages`, or `cache` to
change scope. Go and Python use the active project environment. Java API
members are shown one level at a time (package classes, then class signatures).
Python help and Node export inspection import the selected package, which runs
that package's initialization code. Node API Markdown is read from
`~/.local/src/node`; set `NODE_SOURCE_DIR` to another Node source checkout to
use its docs. The checkout currently on this machine is Node 27.0.0 while the
installed runtime is Node 25.8.0, so some local Node docs may describe newer APIs.

# Scratch!

setting up bare env vim, ideally no tmux (why?)

Working with Clojure REPL
other REPLs

vim only really..

ability to run test suite and compile projects

also ability to run multiple processes at the same time (think LVH stack)

---

## Why no tmux?

tmux is great but overkill and leads spiralling complexity.

[experiment] bringing back tmux but not by default, this is so I can run agents
in the background and do multitasking which in principal I am against as focused
work in theory should be the most effective approach.

Plan here is to keep to just a single window (bg services can still be used with
PM) - if we going to multitask let's be honest and keep it all in the front view

## Vim syntax not working? Typescript slow?

I recently removed some old lines that I am not sure are needed anymore:

```
autocmd BufEnter * :syntax sync fromstart " syntax highlights from the beginning
of the file, sometimes syntax would be broken without it.
set re=2 " forces newer NFA syntax engine
```
