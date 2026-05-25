# :trident: Shell

_A collection of tools I use for development work._

- These tools should be lightweight, my work focus is on
  developing software that solves problems.
- This setup was created with a spartan mindset driving it.
  Constraints enforce deeper engagement.
- To get started, download this repo and run `./bin/reload`. This supports Mac OS
  and Arch Linux. This symlinks all the bin/config files so you can run
  `reload` in future.

# Languages supported

_Primarily

1. Clojure
2. Javascript/Typescript
3. Java
4. Go
5. Bash (yes bash is considered a first-class language)

_Secondarily_

6. Python
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
