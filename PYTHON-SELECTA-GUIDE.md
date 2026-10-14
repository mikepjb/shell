# Build a tiny Python Selecta

A learning project, not a request to port all 650 lines of `bin/selecta`. Build a **single executable Python 3 script** at `bin/spear`, using only the standard library. Keep `bin/selecta` and `config/vimrc` unchanged until the new program works in Vim.

**Goal:** `fd -t f . . | ./bin/spear` displays a small selector *in the current terminal*, then prints exactly one selected path to stdout. It must also work in `config/vimrc`'s `system(a:cmd . ' | selecta')`: stdin contains candidates, `/dev/tty` handles interaction, stdout contains only the choice. Do not use `input()` for keys or print the UI to stdout.

Work through the steps in order. Run each check before moving on. Start with ASCII filenames and keys; add Unicode, resizing, styling, and exact Selecta compatibility only after the simple version works.

## 1. Read paths, select the first one

Learn: shebangs, `sys.stdin`, lists, functions, and the `if __name__ == '__main__'` guard.

```python
#!/usr/bin/env python3
import sys


def read_choices():
    return [line.strip() for line in sys.stdin if line.strip()]


def main():
    choices = read_choices()
    if choices:
        print(choices[0])


if __name__ == '__main__':
    main()
```

Make it executable with `chmod +x bin/spear`. Check:

```sh
printf '  alpha  \n\nbeta\n' | ./bin/spear   # alpha
```

The existing Bash selector strips leading/trailing whitespace and drops empty lines. This is acceptable for parity, though it means paths whose names begin or end with spaces cannot round-trip. Preserve the original (trimmed) text for output; do not print the lowercase matching copy.

## 2. Pure matching logic (no terminal code yet)

This section is several small exercises, **not one leap to the final algorithm**. Add functions above `main()` in `bin/spear`; leave `main()` printing the first choice for now. Everything here can be checked without an interactive terminal.

### 2a. Find a subsequence

A *subsequence* has characters in order but not necessarily side by side: `abc` matches `a/b-c`. Python's `text.find(character, start)` returns an index at or after `start`, or `-1` if absent. Indices start at zero: in `a/b-c`, the letters are at 0, 2 and 4.

```python
def find_match(text, query):
    text = text.lower()
    query = query.lower()
    position = 0             # where the next search starts
    start = None              # location of the first matched character

    for character in query:
        found = text.find(character, position)
        if found == -1:
            return None
        if start is None:
            start = found
        position = found + 1  # next character must come AFTER this one

    if start is None:          # empty query: handled by rank() below
        return None
    return (start, position - 1)  # inclusive end index
```

Trace `find_match('a/b-c', 'abc')`: `position` goes 0 → 1 → 3 → 5; result `(0, 4)`. Try `find_match('acb', 'abc')`: why does it return `None`? This deliberately simple function does **not** yet choose the best of several possible starting `a`s.

Test `bin/spear` even though it lacks a `.py` suffix using `runpy`. The `if __name__ == '__main__'` guard prevents `main()` running when loaded this way:

```sh
python3 - <<'PY'
import runpy
find_match = runpy.run_path('bin/spear')['find_match']
assert find_match('a/b-c', 'abc') == (0, 4)
assert find_match('acb', 'abc') is None
assert find_match('AbC', 'abc') == (0, 2)
print('subsequence OK')
PY
```

### 2b. Search a list

Write `rank(choices, query)`. For an empty query, return `[(0, None, None), (1, None, None), ...]` in input order; `None` means there is no range to highlight. Otherwise loop with `enumerate(choices)` (which supplies both index and text), call `find_match`, skip `None`, and append `(index, start, end)` to a results list. **No sorting yet.** The index lets you print the original choice later, rather than its lowercase matching copy.

Check the shape and ordering:

```sh
python3 - <<'PY'
import runpy
rank = runpy.run_path('bin/spear')['rank']
assert rank(['alpha', 'beta'], '') == [(0, None, None), (1, None, None)]
assert rank(['a/b-c', 'acb', 'ABC'], 'abc') == [(0, 0, 4), (2, 0, 2)]
assert rank(['one', 'two'], 'zzz') == []
print('list matching OK')
PY
```

Stop here if your first goal is a working selector. Plain matching is useful already; you can return to scoring after the UI works.

### 2c. Add Selecta-style ranking (optional until the UI works)

Why not use the *first* match? With query `ab`, `a---ab` has two starting positions. The later `ab` is contiguous and should beat the earlier, spread-out match. For each position containing the query's first character, greedily match the remaining characters, calculate a score, and keep the **lowest** score. Don't replace the winner on a tie: that preserves the earlier start.

In `bin/selecta`'s `refresh_matches()`, score starts at 1. For each later matched character at `found`, compared to previous position `last`:

| Situation | Score change | Remember |
| --- | --- | --- |
| `found == last + 1` | +1 only on entering a consecutive run | `'sequential'` |
| Character before `found` is not a letter, digit, or `_` | +1 only on entering a boundary run | `'boundary'` |
| Otherwise | `+(found - last)` | `'normal'` |

Keep `last_type`, initially `None`, to implement “only on entering a run”. For example, query `abc` against `abc` scores 2, *not* 3: the `b` enters a consecutive run and the `c` stays in it. Implement a separate `score_from(text, query, first)` returning `(score, end)` or `None` if the rest of the query cannot be found. Use `.find(query[i], last + 1)` for each remaining character. An ASCII boundary check can be `not (previous.isascii() and (previous.isalnum() or previous == '_'))`.

Then, inside `find_match`, try successive first-character locations with `.find(query[0], search_from)` and `search_from = first + 1`. Use `score_from` for each; return `(score, start, end)` for the best. Update `rank` to build sortable pairs:

```python
sort_key = (score, end - start + 1, len(choice), index)
results.append((sort_key, (index, start, end)))
# after the loop:
return [match for key, match in sorted(results)]
```

Keep empty-query results in input order. Check ties: `rank(['ABC', 'abc'], 'abc')` should preserve indices 0 then 1. Check whether `rank(['a---ab', 'ab'], 'ab')` ranks the short, contiguous match first. If this step feels complicated, **leave it until after step 5**.

### Make the checks repeatable

The shell snippets are quick experiments; turn them into `tests/test_spear.py` when ready. Because `bin/spear` has no `.py` extension, load its functions with `runpy.run_path`:

```python
import runpy
import unittest
from pathlib import Path

spear = runpy.run_path(str(Path(__file__).resolve().parents[1] / 'bin/spear'))


class MatchingTests(unittest.TestCase):
    def test_noncontiguous_match(self):
        self.assertEqual(spear['find_match']('a/b-c', 'abc'), (0, 4))
```

Add tests for empty queries, case, no matches, ties, and paths with spaces. Once you implement 2c, `find_match` returns three values, so **update the 2a test** to expect `(score, start, end)` or test `rank` instead. Run `python3 -m unittest discover -s tests -p 'test_spear.py'`. Keep terminal-related code out of these tests. Lowercase caching and Python-vs-awk Unicode differences can wait until you have a measured performance or compatibility problem.

## 3. Open the terminal separately

Learn: file descriptors, `try/finally`, `termios`, `tty`, and why stdin and stdout must not be commandeered here.

```python
import os
import termios
import tty

with open('/dev/tty', 'r+b', buffering=0) as terminal:
    fd = terminal.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setcbreak(fd)  # keys arrive without Return; Ctrl-C still signals
        key = os.read(fd, 1)  # bytes, not a Python string
        terminal.write(b'key received\r\n')
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
```

First make a tiny experiment that exits on Return. Use `try/finally` **before** building the UI, or a crash can leave your terminal without normal input. `stty sane` in your shell is a recovery command. Catch `KeyboardInterrupt` outside the `with` block and exit without printing a choice. A missing `/dev/tty` should produce a short error on stderr and a nonzero exit, not a traceback in routine usage.

Check interactively:

```sh
printf 'alpha\nbeta\n' | ./bin/spear
```

Press a key; verify the debug message appears in the terminal but **not** in redirected stdout: `printf 'alpha\nbeta\n' | ./bin/spear > /tmp/selecta-choice`. Remove the debug message once this passes.

## 4. The smallest useful interaction

State can be just `choices`, `query = ''`, `matches = rank(choices, query)`, and `cursor = 0`. Read one byte at a time with `os.read(fd, 1)`:

- Printable ASCII: append `chr(key[0])` to the query, rerank, reset cursor to 0.
- Backspace (`b'\x7f'` or `b'\x08'`): remove the last query character and rerank.
- Ctrl-N (`b'\x0e'`) / Ctrl-P (`b'\x10'`): move the cursor through displayed matches.
- Return (`b'\r'` or `b'\n'`): choose the highlighted result, or nothing if there is no match.
- Ctrl-U (`b'\x15'`): clear the query.

Initially display only the prompt, match count, and first **up to ten** results. Add arrow keys, Ctrl-W, highlighting, and UTF-8 input later. Escape keys arrive as *multiple bytes*: do not treat the first `b'\x1b'` as a printable query character; defer arrow support until you can parse escape sequences with a short timeout (`select.select`). Note: the old selector restricts movement to visible results; doing that here is a reasonable v1 choice.

## 5. Draw inline, not full-screen

Learn: ANSI escape sequences and rendering a complete frame rather than editing individual characters. Write **all** UI bytes to `terminal`, never `sys.stdout`. Use `os.get_terminal_size(fd)` to cap the display to the available terminal height and width. A simple frame is a prompt plus a fixed number of result rows; fill missing rows with blanks. Clear each row with `\x1b[2K\r`, write its contents, and move the cursor back up to the prompt after the last row. On exit move below the frame, show the cursor if you hid it, and restore terminal settings in `finally`. `redraw!` in the existing Vim function handles the leftover display after selection.

Keep v1 plain: no ANSI colouring of matches, no attempts to account for double-width Unicode. Cap **each displayed row** to the terminal width and make sure candidate strings containing terminal control characters cannot inject escape sequences into the UI. The selected stdout value must remain the unmodified candidate. Test with 0, 1, and 100 candidates, a narrow terminal, Enter, and Ctrl-C.

Only after closing `/dev/tty` and restoring its settings, emit the result with `print(choices[selected_index])`. On cancellation or zero matches, write **nothing** to stdout. Never put status/debug messages there.

## 6. Validate in Vim before replacing anything

Temporarily try this in Vim:

```vim
:let picked = trim(system("printf 'alpha\nbeta\n' | ./bin/spear"))
:echo string(picked)
```

Then try your existing `Selecta()` function with `selecta` replaced **temporarily** by the new script path and the existing `fd` command. Check Enter, cancellation, Ctrl-C, redraw, long filenames, and paths with spaces. Only change `config/vimrc` once this works reliably. You can keep the Bash version as a fallback.

## 7. Measure before optimising

Time two things separately: cold start (launch + read candidates + first frame) and **refresh latency for each query character** (rank + draw). Test 1k, 10k, and 50k paths with the same inputs and query sequence in both implementations. `time` alone measures whole-run time, not interactive keystroke latency; `time.perf_counter()` around `rank()` is an easy first measurement. Avoid logging timings to stdout; use stderr or a separate file while developing.

Start with a complete `sorted()` result each keystroke. If profiling shows matching is slow, limit re-searching to previous matches *while appending characters* (backspace must broaden the search). If sorting is slow and only the first ten results can be selected, count all matches but use `heapq.nsmallest(10, matches, key=...)` to rank just the visible ones. Don't introduce either optimisation until tests pass: both make the state and edge cases harder to reason about.

**Done means:** stdlib-only, one script, ranking tested without a terminal, no UI on stdout, terminal restored on every exit path, and selection tested inside Vim. The aim is a selector you understand, not a byte-for-byte clone of Bash Selecta.
