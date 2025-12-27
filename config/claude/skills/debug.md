---
name: debug
description: Investigate and resolve production issues, bugs, and unexpected behavior. Use this skill when troubleshooting errors, analyzing logs, tracing request flows, or diagnosing performance problems in web services.
---

# Debug Skill

Systematically investigate and resolve issues in web services.

## Process

1. **Reproduce**: Understand how to trigger the issue
2. **Gather evidence**: Collect logs, errors, stack traces
3. **Form hypothesis**: What might be causing this?
4. **Trace the flow**: Follow the request/data path
5. **Isolate**: Narrow down to the specific cause
6. **Fix & verify**: Implement fix and confirm resolution

## Information Gathering

### From the User
- Error messages or symptoms
- When did it start? What changed?
- Affected users/requests (all or specific?)
- Steps to reproduce

### From Logs
- Application logs around the time of issue
- Request IDs / correlation IDs
- Stack traces
- Database query logs

### From Code
- Recent changes (git log, blame)
- Error handling paths
- External service calls

## Common Web Service Issues

### 500 Internal Server Error
1. Check application logs for stack trace
2. Look for unhandled exceptions
3. Check database connectivity
4. Verify external service availability
5. Check for null/undefined handling

### Slow Responses
1. Check database query performance (N+1, missing indexes)
2. Look for external API latency
3. Check for blocking operations
4. Review connection pool exhaustion
5. Look for memory pressure / GC pauses

### 4xx Errors
- **400**: Validation failures - check request payload
- **401**: Auth issues - check token/session validity
- **403**: Permission issues - check authorization logic
- **404**: Routing issues - check URL and route definitions

### Data Issues
1. Check recent migrations
2. Look for race conditions
3. Verify transaction boundaries
4. Check for caching staleness

### Intermittent Failures
1. Look for race conditions
2. Check connection pool limits
3. Look for timeout configurations
4. Check external service reliability
5. Review retry logic

## Debugging Techniques

### Request Tracing
```
Request ID → API Handler → Service Layer → Database → Response
```
Follow the request through each layer.

### Binary Search
If issue is in a range of commits:
1. Find a known good state
2. Find the bad state
3. Test the middle
4. Repeat until isolated

### Minimizing Reproduction
1. Start with full reproduction case
2. Remove variables one at a time
3. Find minimum case that still fails

## Output Format

```markdown
## Debug Report

### Issue
Brief description of the problem

### Evidence
- Error messages
- Relevant log entries
- Stack traces

### Root Cause
What is actually causing the issue

### Location
- `path/to/file.ts:45` - The problematic code

### Fix
Recommended solution

### Verification
How to confirm the fix works

### Prevention
How to prevent similar issues (tests, monitoring, etc.)
```

## Guidelines

- Don't guess - gather evidence first
- Check the obvious things (config, connectivity, permissions)
- Use request IDs to trace specific failures
- Look for patterns (time-based, user-based, data-based)
- Consider recent changes as prime suspects
- Document findings for future reference
