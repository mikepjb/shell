# :trident: Shell

_A collection of tools I use for development work._

- These tools should be lightweight, my work focus is on
  developing software that solves problems.
- This setup was created with a spartan mindset driving it.
  Constraints enforce deeper engagement.
- To get started, download this repo and run `./bin/reload`. This supports Mac OS
  and Arch Linux. This symlinks all the bin/config files so you can run
  `reload` in future.

## Vendor browser assets

Run `vendor htmx alpine` from a project directory to download pinned, browser-ready
assets into `./vendor/` (no npm needed). Use `vendor --list` to see the supported
libraries, or `vendor --dir static/js htmx jquery react` to choose a directory.
Also available: `sortable`, `chartjs`, `hyperscript`, `phosphor`, and `openprops`.
`openprops` downloads `open-props.min.css` (design tokens, not a styled UI).
Phosphor vendors the regular icon font and its CSS; include `phosphor/style.css`
in your page. React downloads both React and ReactDOM (version 18 UMD builds); load React
before ReactDOM. Files already present are not overwritten. Delete a file before
running `vendor` again to replace it. Requires `curl`.

## Shell Reference


- `find . | grep org$ | xargs -o vi` opens a bunch of files in vim (you can
  flick through the with :next). `-o` is the key ingredient here which
  reconnects Vim's stdin back to the terminal.

## Devtools Reference

- Settings (cog icon) => Preferences => Elements => Rulers on hover

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

### REPLs == fast feedback loops

- Whether you have a REPL or not, the ideal here is to have something to be able
  to evaluate your code quickly.
- This doesn't have to be something like Clojure's REPL but can be unit tests.
- Really the focus here is "fast feedback loops are king", a REPL is just one
  variant of this solution.

#### More REPL detail

- REPLs are powerful because they provide the ability to test theory.
- IMO there are many variations to this, for example being able to run tests
  quickly in vim is another form of REPL.
- While there is value is having a "proper" REPL, meaning something that can
  accept/read input and provide a result, (fast!) test suites can also provide
  the same thing.
- Conclusion here is that you don't always need a real REPL, but having the
  ability to run the current file instantly in vim or to run a test suite (and
  the execution of that test suite is also very fast) covers enough of the
  benefits and avoids certain drawbacks (i.e maintaining mutable state).
- So this is what I optimise for.
- When you are using a new library, a REPL can be really good for figuring out
  how to work with it. On the other hand, a single file script can also work
  well.
- For Golang, it compiles so fast unit tests work well. Same for JUnit and Java.
- Bash scripts & unit tests can be saved for future reference. The state of a
  REPL is ephemeral.

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
