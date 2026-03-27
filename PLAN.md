# Pluginless Clojure nREPL Client for Neovim

Build a single-file nREPL client (`config/clojure.lua`) to replace replica.nvim plugin and integrate with pluginless neovim setup.

## Feature Inventory (from replica.nvim)

### Currently Implemented ✅
1. **nREPL Connection** - TCP socket, session management, bencode protocol
2. **Code Evaluation** - `:Eval <code>`, visual range, namespace-aware
3. **Testing** - `:Test`, `cpr` (require+test), `cpR` (reload-all+test)
4. **Documentation** - `:Doc <symbol>` lookup
5. **Namespace Detection** - infer from file path + source roots
6. **ClojureScript Support** - `:CljsConnect [shadow|figwheel]`
7. **Quasi-REPL** - `cqp` prompt in current namespace
8. **Convenience** - `:Connect`, `:Require`, `:History`

### Not Implemented / Deferred ❌
- Treesitter form extraction (Phase 5 is optional)
- Full REPL buffer interaction
- REPL history/readline
- Fireplace-style operators
- Omni-completion
- Require-on-save
- Project config (`.dir-locals.el` style)
- Connection health monitoring

---

## Implementation Plan: 7 Phases

### Phase 1: Foundation (Bencode + Socket + Test)
**Goal:** Prove bencode/socket work, establish test harness

**Tasks:**
- [ ] Inline bencode encoder
- [ ] Inline bencode decoder (stateful)
- [ ] vim.loop TCP socket wrapper
- [ ] `:Hello` command - sends `(+ 40 2)`, captures + prints response
- [ ] Basic logging (vim.notify)

**Files:** `config/clojure.lua` (start ~200 LOC)

**Acceptance:** `:Hello` evaluates and prints result from nREPL

**Estimate:** 1-2 hours

---

### Phase 2: Basic `:Eval` Command
**Goal:** User-facing eval with output capture

**Tasks:**
- [ ] `:Eval <code>` - inline evaluation
- [ ] `:Eval` (visual range) - selected lines
- [ ] Buffer response logic - collect out/err/value until done status
- [ ] Log output to messages/notifications
- [ ] Session routing (main session by default)

**Files:** `config/clojure.lua` (~400 LOC total)

**Acceptance:** `:Eval (+ 2 3)` prints `5`

**Estimate:** 1-2 hours

---

### Phase 3: Auto-Connect via `.nrepl-port`
**Goal:** Seamless first-time setup

**Tasks:**
- [ ] Read `.nrepl-port` from project root
- [ ] Auto-connect on first `:Eval` if not connected
- [ ] Connection state tracking (connected? port?)
- [ ] Error handling - missing port, dead connection
- [ ] Optional: `:Connect [port]` manual override

**Files:** `config/clojure.lua` (~500 LOC total)

**Acceptance:** Open clojure file in nREPL project, `:Eval` works without manual connect

**Estimate:** 30-45 min

---

### Phase 4: In-REPL Prompt (`cqp`)
**Goal:** Interactive prompt inside neovim

**Tasks:**
- [ ] `cqp` keymap → `vim.ui.input()` with "ns=> " prompt
- [ ] Detect current namespace from buffer path
- [ ] Eval user input in that namespace
- [ ] Print result to messages

**Files:** `config/clojure.lua` (~550 LOC total)

**Acceptance:** `cqp` shows namespace prompt, evaluation works

**Estimate:** 45 min

---

### Phase 5: Form Extraction (`cpp`)
**Goal:** Eval sexp at cursor (or fallback to line)

**Tasks:**
- [ ] If treesitter available: extract current form under cursor
- [ ] Fallback: current line if treesitter unavailable
- [ ] `cpp` keymap
- [ ] Eval form and print result

**Files:** `config/clojure.lua` (~600 LOC total)

**Acceptance:** `cpp` on `(+ 1 2)` evaluates it

**Estimate:** 1-2 hours (treesitter integration can be tricky)

---

### Phase 6: Require + Test Commands
**Goal:** Common workflow operations

**Tasks:**
- [ ] `:Require` / `:Require!` (reload / reload-all)
- [ ] `:Test` - run tests for current namespace
- [ ] `cpr` - require + test
- [ ] `cpR` - require! + test
- [ ] `:Doc <symbol>` - docstring lookup
- [ ] Separate test session (clj_test) to avoid printer side effects

**Files:** `config/clojure.lua` (~700 LOC total)

**Acceptance:** `cpr` reloads namespace and runs tests, output printed

**Estimate:** 1-2 hours

---

### Phase 7: Integration into init.lua
**Goal:** Wire it up to pluginless config

**Tasks:**
- [ ] Load `clojure.lua` on clojure filetype
- [ ] Auto-connect on clojure buffers
- [ ] Add keybinds to `config/init.lua` (replace tmux integration)
- [ ] Optional: auto-eval namespace on save
- [ ] Replace/augment existing tmux REPL keybinds

**Files:** `config/init.lua`, `config/clojure.lua`

**Acceptance:** Works alongside current tmux setup, then gradually replace it

**Estimate:** 30 min

---

## Notes

- **Treesitter optional:** Phase 5 can fallback gracefully if treesitter unavailable
- **Session management:** Start simple (one main session), add clj_test for test runs
- **Error handling:** Keep it simple - vim.notify for errors, preserve user's debug workflow
- **Testing:** Manual testing with real nREPL; no unit test harness (pluginless approach)
- **Compatibility:** Maintain with your current tmux keybinds during transition

---

## Success Criteria (End Goal)

- Single file: `config/clojure.lua` (~700-800 LOC)
- No external dependencies (just neovim built-ins)
- Works with your pluginless init.lua
- Replaces tmux REPL for basic Clojure development
- Can extend later with more features as needed
