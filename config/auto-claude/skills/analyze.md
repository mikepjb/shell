---
name: analyze
description: Gather context before planning or implementation. Use this skill when starting any non-trivial task to understand the codebase, trace data flow, and collect relevant information. Can also search the web for documentation or patterns.
---

# Analyze Skill

Gather comprehensive context before any planning or implementation work.

## Process

1. **Understand the request**: What is the user trying to achieve?
2. **Search the codebase**: Find relevant files, patterns, and dependencies
3. **Trace data flow**: Understand how data moves through the system
4. **Check for existing patterns**: Note conventions to follow
5. **Web search if needed**: Look up documentation, libraries, or best practices

## Tools to Use

- `Glob` - Find files by pattern
- `Grep` - Search for code patterns and usages
- `Read` - Examine file contents
- `LSP` - Find definitions, references, call hierarchies
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

### Relevant Files
- `path/to/file.ts:10-50` - Description of what this contains

### API Routes
- `GET /api/v1/resource` - Handler in `handlers/resource.ts:25`

### Database
- Tables involved: `users`, `orders`
- Relevant migrations: `20240101_add_status.sql`

### Key Patterns
- Pattern name: How it works

### Dependencies
- What depends on what

### Considerations
- Important constraints or notes
```

## Guidelines

- Be thorough but concise - include only what's relevant to the task
- Always include file:line references for traceability
- Note any ambiguities that need clarification in the plan stage
- Identify potential risks or complications early
