# :trident: Shell

_A collection of tools I use for development work._

- These tools should be lightweight, my work focus is on
  developing software that solves problems.
- This setup was created with a spartan mindset driving it.
  Constraints enforce deeper engagement.
- Fast editing matters more to me than deep language support. Every pause to
  work around a tool risks breaking my train of thought, especially when I'm
  several layers into a problem.
- To get started, download this repo and run `./bin/reload`. This supports Mac OS
  and Arch Linux. This symlinks all the bin/config files so you can run
  `reload` in future.

A key principle that underlies this setup is, prefer operational reliability >
automation. A good example here is preferring `:!test-this` > `:make test-this`
which would collect the test script output and populate a quickfix window.
Rather than maintain the quickfix format, it is simpler to just read and
remember the important part of the output and fuzzy find/navigate myself.

Emacs still draws me in, but even a vanilla, low-maintenance setup gives up
Vim's editing speed and leaves plenty of integration work. I suspect VS Code
and IntelliJ involve a similar tradeoff: deeper language support that can
break, versus fast editing and navigation with Vim and ctags.

Finally, we have to mention LLMs. Our relationship with AI tools is constantly
evolving and I think there are largely 3 schools of thought here:
- No AI
- Minimal reasoning, fast models, tight human control
- Frontier models with light or no human control

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
  flick through them with `:next`). `-o` is the key ingredient here which
  reconnects Vim's stdin back to the terminal.

## Devtools Reference

- Settings (cog icon) => Preferences => Elements => Rulers on hover

## LLM usage

- Primarily Local LLMs are used for their speed to help a human programmer get
  unstuck, providing useful analysis & feedback via the `./bin/consult` script.
- For agentic work, `pi` harness with Sol/GLM 5.3/Kimi K3 with minimal AGENTS.md
  direction (post mid-2026 less is more it seems)

## Languages supported

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

## Ctags

A tool used to index projects and make it easier to navigate. Like Vim, the more I understand this tool, the better leverage I'm going to get out of it.

Mainly used to enable jumping to code you are using, instead of autocomplete it is expected that I will read the module/class source I want to use. More time initially as a trade for better understanding.

So running `ctags -R .` without config on a node project is going to get me a tags file that I can use.. but it will index `node_modules` LOL and that isn't necessarily what I want.

You can use `:tags /search_term` to search your tags file inside vim.

## Navigation

- `:grep` will grep and populate the results in a quickfix list. Remember to use `%` for the current file and `-r` and `.` if you want to do a project wide search.

- `:grep` inside vim is super useful, i.e `:grep TODO %` to list and move between all TODOs in the current file.

- `tv` runs tree and less together to give a view of the current project
  filesystem.
- `C-;` in Vim opens and toggles Netrw for a similar filesystem view but this
  isn't fully expanded. Still it's good to navigate smaller areas.

## Deeper Detail & Reasoning

### Fast feedback loops

A REPL is useful for testing ideas and exploring unfamiliar libraries, but the
important thing is getting feedback quickly. Running the current file in Vim,
a fast test suite (Go or JUnit, for example), or a small Bash script can serve
the same purpose without maintaining mutable REPL state. Tests and scripts also
leave behind a reusable record of what worked.

### Keep tmux focused

Bash starts in tmux so agents and other long-running work can keep running. The
working view is one window with at most two panes: `M-o` splits it or switches
between panes. `M-i` toggles zoom on the current pane: the other pane stays in
the window and keeps running, but is out of view while zoomed. With only one
pane, `M-i` does nothing.
Avoid accumulating windows and panes just because tmux makes it easy; keep the
work you're doing in view.

### Editors

- Despite Emacs offering many alluring reasons to choose it (mainly org-mode
  being the killer application), Vim is the choice I keep coming back to:
  - Very portable (available everywhere) and very compatible (no meta/special
    keys that sometimes do not work with terminal emulators).
  - The most important thing here is relying on tools that don't break.

### Vim syntax not working? Typescript slow?

I recently removed some old lines that I am not sure are needed anymore:

```
autocmd BufEnter * :syntax sync fromstart " syntax highlights from the beginning
of the file, sometimes syntax would be broken without it.
set re=2 " forces newer NFA syntax engine
```
