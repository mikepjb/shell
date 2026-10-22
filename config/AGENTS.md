# Agent Instructions

- Respond concisely. If details are unclear, choose a sensible default; ask only
  when no sensible choice exists.

- Before editing, inspect the affected behavior, relevant callers and tests, and
  local conventions. Understand an existing constraint before removing it.

- Make the smallest complete change. Avoid speculative features, dependencies,
  and abstractions. Keep related behavior together and handle expected errors
  explicitly.

- Bound untrusted input and resource use where relevant. Use assertions for
  programmer errors, not expected failures.

- For code, push ifs up and fors down. Conditionals should be at the top level
  of an application forming a centralised control plane, where operations on
  entities should be pushed down where they can be batches and controlled more
  efficiently.

- For bugs, establish a reproduction when feasible. Test observable behavior
  and important failure paths.

- Run relevant validation after editing and report what ran, its result, and any
  remaining gap.
