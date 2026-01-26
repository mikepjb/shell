---
name: analyze
description: Gather context before guiding. Use this skill when starting any task to understand the codebase, trace data flow, and collect relevant information. Can also search the web for documentation or patterns.
---

# Analyze Skill

Gather comprehensive context to provide informed guidance.

## Process

1. **Understand the request**: What is the user trying to achieve?
2. **Search the codebase**: Find relevant files, patterns, and dependencies
3. **Trace data flow**: Understand how data moves through the system
4. **Check for existing patterns**: Note conventions to follow
5. **Web search if needed**: Look up documentation, libraries, or best practices
6. **Spawn subagents**: For complex tasks, use multiple explore agents in parallel

## Depth Adjustment

Scale your investigation to the task:
- **Simple** (button color, typo): Lightweight search, quick scan
- **Medium** (new endpoint, bug fix): Thorough file search, pattern matching
- **Complex** (new feature, architecture): Multiple subagents, deep tracing, web research

## Tools to Use

- `Task` with `Explore` subagent - For open-ended codebase exploration
- `Glob` - Find files by pattern (when you know what you're looking for)
- `Grep` - Search for code patterns and usages
- `Read` - Examine file contents
- `WebSearch` / `WebFetch` - External documentation and patterns

## Web Service Context

For web service tasks, specifically gather:

### API Layer
- Route definitions and URL patterns
- Request/response schemas
- Middleware chain (auth, validation, logging)
- API versioning approach

### Data Layer
- Database schema and relationships
- Migration history and patterns
- ORM/query patterns used
- Connection pooling setup

### Auth & Security
- Authentication mechanism (JWT, sessions, API keys)
- Authorization patterns (RBAC, permissions)
- Input validation approach

### External Integrations
- Third-party APIs and SDKs
- Message queues / event systems
- Caching layer (Redis, etc.)

### Config & Environment
- Environment variable patterns
- Feature flags
- Secrets management

## Output Format

Produce a concise markdown summary:

```markdown
## Context Summary

### Task Understanding
Brief restatement of what the user wants to accomplish.

### Relevant Files
- `path/to/file.ts:10-50` - Description of what this contains
- `path/to/other.go:123` - Related functionality

### Key Patterns Found
- Pattern name: How it's currently used in the codebase
- Convention: What the codebase consistently does

### Data Flow
How data moves through the system for this feature.

### Dependencies
- What depends on what
- External libraries or services involved

### Considerations
- Important constraints or edge cases
- Potential gotchas to watch for
- Areas that might be impacted by changes

### Questions to Explore in Guide Phase
- Ambiguities that need resolution
- Trade-offs to discuss with user
```

## Complexity Detection

Watch for complexity demons during analysis:

**Abstraction Overkill**
- Interfaces with only one implementation
- Wrapper classes that just pass through calls
- Generic types used for only one type
- Helper functions called only once

**Over-Decomposition**
- 10 files with 20 lines each instead of 1 file with 200 lines
- Excessive indirection: A calls B calls C calls D to do simple thing
- Classes that exist just to separate "concerns"

**Premature Optimization**
- Caching before measuring
- Complex data structures for small datasets
- "Extensibility" for hypothetical future use

**Flag these in your analysis output.** Help the programmer see complexity demons before they multiply.

## Guidelines

- Be thorough but concise - include only what's relevant to the task
- Always include file:line references for traceability
- Note any ambiguities that need clarification in the guide phase
- Identify potential risks or complications early
- Don't propose solutions yet - that's for the guide phase
- Watch for and call out complexity demons in existing code
