# LLM Model Test Prompts

## Coding (test quality, accuracy, edge cases)

1. **Email validation**
   ```
   Write a function that validates an email address. Handle edge cases.
   ```

2. **Bug finding**
   ```
   Find the bug in this code: [paste some intentionally broken code]
   ```

3. **Data structure implementation**
   ```
   Implement a binary search tree with insert, delete, and search methods.
   ```

4. **Testing**
   ```
   Write unit tests for a shopping cart function.
   ```

5. **Code refactoring**
   ```
   Refactor this code to be more readable: [messy code]
   ```

**What to look for**: Does it handle edge cases? Does it know common pitfalls? Is the code actually correct?

---

## Writing (test prose quality, creativity, coherence)

1. **Blog post introduction**
   ```
   Write a technical blog post introduction about [your topic].
   ```

2. **Paragraph rewrite**
   ```
   Rewrite this paragraph to be more engaging: [boring text].
   ```

3. **Product description**
   ```
   Write a short product description that sells without being salesy.
   ```

4. **Explanation simplification**
   ```
   Explain [complex concept] like I'm 10 years old.
   ```

**What to look for**: Flow, voice consistency, whether it actually understands the concept or just sounds smart.

---

## Reasoning (test logic, multi-step thinking)

1. **Simple math problem**
   ```
   I have 5 apples. I give 2 to Alice, 1 to Bob. Alice gives half of hers to Charlie. How many apples does each person have?
   ```

2. **Logic puzzle**
   ```
   If all roses are flowers and some flowers fade quickly, can we conclude all roses fade quickly? Explain.
   ```

3. **Troubleshooting**
   ```
   What are the first 3 steps to debug a slow database query?
   ```

**What to look for**: Does it break down multi-step problems correctly? Does it catch logical fallacies?

---

## Speed/Latency (measure token/s)

1. **Quick response**
   ```
   Hello, what's your name?
   ```
   (should be instant)

2. **Long-form generation**
   ```
   Write a 500-word essay on [topic]
   ```
   (measure token/s, notice the lag)

---

## Consistency/Hallucination (repeat prompts, check for stability)

1. **Factual consistency check**
   - Ask the same factual question twice, see if answers match

2. **Obscure fact generation**
   - Ask it to list facts about something obscure — does it make stuff up?

---

## Testing Strategy

**Quick validation**: Pick 2-3 prompts from each category.

**Reference baseline**: Run them against `qwen3-coder-30b-a3b` first, then compare:
- `qwen3-4b` (fast small coder)
- `devstral-small-2` (alternative coder)
- `qwen3-14b` (if you add it for writing)

**Edge cases**: The tiny models (0.6B, 1B) are more for benchmarking "how small can I go" than actual use — they'll be entertaining but probably not practically useful.

**What matters**:
- Coding: correctness > speed
- Writing: quality > speed
- Speed: only matters if quality is acceptable
