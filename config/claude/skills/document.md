---
name: document
description: Build documentation with the programmer after implementation. Ask questions to ensure understanding and capture decisions. Creates concise, maintainable docs in ./docs folder.
---

# Document Skill

Collaboratively build documentation that captures what was done and why.

## Core Principle

**Documentation is for future you and your team.**

Through conversation, ensure the programmer:
- Understands what they just built
- Can explain why they made key decisions
- Has captured the essential knowledge for later reference

**Grug wisdom: Documentation can harbor complexity demons too.**

Bad documentation is worse than no documentation:
- Verbose docs that nobody reads
- Over-detailed explanations of simple things
- Documentation that goes stale because it's too much work to maintain
- Clever formatting that obscures the actual information

Keep it simple. Keep it short. Keep it maintainable.

## Process

1. **Ask about the implementation**: What did they build?
2. **Understand the decisions**: Why this approach?
3. **Explore the impact**: What might be affected?
4. **Capture edge cases**: What gotchas exist?
5. **Write concise docs**: Extract the essential knowledge
6. **Place in ./docs**: Number by generality (01-, 02-, etc.)

## What to Document

**YES - Document these**:
- New features (how they work, why they exist)
- Bug fixes (non-obvious ones: what was wrong, how it was fixed)
- Important learnings (gotchas discovered, patterns established)
- Architectural decisions (trade-offs, alternatives considered)

**NO - Skip these**:
- Refactoring (unless it changes behavior/architecture)
- Trivial changes (typos, formatting)
- Self-evident code changes

## Questions to Ask

### Understanding the Change
- "Walk me through what you implemented"
- "What was the trickiest part?"
- "What alternatives did you consider?"
- "Why did you choose this approach?"

### Impact and Edge Cases
- "What parts of the system does this touch?"
- "What happens if [edge case]?"
- "What could go wrong with this change?"
- "What should future developers watch out for?"

### Testing and Validation
- "How did you test this?"
- "What edge cases are covered?"
- "How would you manually verify this works?"

### Documentation Needs
- "What do you wish you'd known before starting?"
- "What would help someone understand this in 6 months?"
- "Are there any non-obvious interactions?"

## Documentation Format

### File Naming
Place in `./docs` folder, numbered by generality:
- `01-introduction.md` - Project overview
- `02-architecture.md` - System design
- `03-data-model.md` - Database schema
- `04-authentication.md` - Auth system
- `05-feature-name.md` - Specific features

### Structure

```markdown
# [Feature/Change Name]

## Overview
Brief description of what this is and why it exists.

## How It Works
Explain the mechanism at a conceptual level.

## Implementation Details
Key files and what they do:
- `path/to/file.go:123` - Handles X
- `path/to/other.go:45` - Manages Y

## Key Decisions
Trade-offs and why we chose this approach:
- **Decision**: Why we did X instead of Y
- **Trade-off**: What we gained and what we sacrificed

## Edge Cases
Non-obvious scenarios to be aware of:
- What happens when...
- Watch out for...

## Code Example
```go
// Illustrative example showing the key pattern
```

## Testing
How to verify this works:
1. Do X
2. Expect Y
3. Edge case: Try Z

## Future Considerations
What to think about if extending this:
- Limitation: ...
- Possible enhancement: ...
```

## Documentation Principles

### Simple Over Complete
- Extract the essential knowledge
- Skip obvious details
- Focus on "why" over "what"
- Be scannable (headers, bullets, short paragraphs)
- **If in doubt, write less**

### Plain Language
- Write for a tired developer at 2am
- No jargon unless necessary
- No elaborate metaphors or analogies
- Direct and clear beats clever and cute

### Examples Over Explanation
- Show code snippets
- Use concrete examples
- Demonstrate the pattern
- One good example > three paragraphs of explanation

### Ruthlessly Maintainable
- Keep it short (1-2 pages max, preferably 1)
- Update when behavior changes
- **Delete when obsolete** (stale docs are poison)
- If it's getting long, it's probably too detailed

### Traceable
- Link to specific files (path/to/file.go:123)
- Reference related docs
- Note when it was added/changed

### Document Decisions, Not Code
- Code shows WHAT
- Docs explain WHY
- Focus on trade-offs, alternatives considered, gotchas
- Don't restate what the code already says

## Interactive Documentation

Not all Q&A makes it into the docs. Use the conversation to:
- Verify their understanding
- Surface hidden complexity
- Identify what's actually important
- Refine their thinking

Then distill the essential points into concise documentation.

## When Documentation Isn't Needed

If the change is:
- Self-explanatory from the code
- Covered by existing docs
- Too trivial to warrant explanation

Then say:
```
This change is straightforward and self-documenting. No additional docs needed.
```

## Output

After the conversation, either:

1. **Write the documentation**:
   - Propose the doc content
   - Suggest where it goes (./docs/XX-name.md)
   - Ask for approval before creating

2. **Update existing documentation**:
   - Show what needs to change
   - Propose the updates
   - Ask for approval

3. **Skip documentation**:
   - Explain why it's not needed
   - Confirm with the programmer

## Example Conversation

```
Claude: Walk me through what you implemented.
User: I added email validation to the user registration flow.

Claude: What approach did you take?
User: I added a regex check in the handler before creating the user.

Claude: What happens if the email is invalid?
User: It returns a 400 with an error message.

Claude: Did you consider putting validation in the model instead?
User: Yes, but the handler felt more consistent with how we validate other fields.

Claude: Good point. What edge cases did you handle?
User: Empty email, malformed email, duplicate email.

Claude: How do you test for duplicates?
User: I query the database first to check if it exists.

Claude: Great. Let me draft some docs for this...
```

## Guidelines

- Ask open-ended questions, not yes/no
- Listen for complexity, trade-offs, gotchas
- Don't document the obvious
- Keep docs short and scannable
- Focus on future maintainability
- Verify understanding through questions
- **Push back on over-documentation** - if it doesn't need docs, say so
- One page is better than three pages
- Delete more than you write when updating docs

## Complexity Demons in Documentation

Watch for and avoid:

**Over-Documentation**
- Explaining every function (that's what code comments are for, if needed at all)
- Documenting trivial decisions
- Elaborate architecture diagrams for simple systems
- Detailed implementation walkthroughs of straightforward code

**Stale Documentation**
- Docs that don't match current code (delete or fix immediately)
- Version-specific notes that are outdated
- TODO sections that never get done (delete them)
- Historical context that's no longer relevant

**Clever Documentation**
- Elaborate metaphors that confuse more than clarify
- ASCII art diagrams that break when edited
- Custom formatting that's hard to maintain
- "Creative" organization that makes things hard to find

**Documentation for Documentation's Sake**
- "We should document this" without clear reason
- Completionism (documenting everything)
- Following documentation templates rigidly
- Adding docs just to check a box

**If the programmer says "I'm not sure this needs docs"** - they're probably right. Trust that instinct.
