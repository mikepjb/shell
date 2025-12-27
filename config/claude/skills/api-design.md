---
name: api-design
description: Design REST and GraphQL APIs with consistent patterns. Use this skill when creating new endpoints, designing resource schemas, or planning API structure for web services.
---

# API Design Skill

Design clear, consistent, and practical APIs for web services.

## Principles

1. **Consistency**: Match existing patterns in the codebase
2. **Simplicity**: Easy to understand and use
3. **Predictability**: Behaves as expected
4. **Evolvability**: Can change without breaking clients

## REST API Design

### URL Structure
```
GET    /api/v1/resources          # List
POST   /api/v1/resources          # Create
GET    /api/v1/resources/:id      # Read
PUT    /api/v1/resources/:id      # Replace
PATCH  /api/v1/resources/:id      # Update
DELETE /api/v1/resources/:id      # Delete
```

### Nested Resources
```
GET /api/v1/users/:userId/orders           # User's orders
POST /api/v1/users/:userId/orders          # Create order for user
GET /api/v1/users/:userId/orders/:orderId  # Specific order
```

Keep nesting shallow (max 2 levels). For deeper relations, use query params:
```
GET /api/v1/orders?userId=123&status=pending
```

### Query Parameters
- **Filtering**: `?status=active&type=premium`
- **Sorting**: `?sort=created_at&order=desc`
- **Pagination**: `?page=2&limit=20` or `?cursor=abc123`
- **Field selection**: `?fields=id,name,email`
- **Search**: `?q=search+term`

### HTTP Methods
| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Read | Yes | Yes |
| POST | Create | No | No |
| PUT | Replace | Yes | No |
| PATCH | Update | Yes | No |
| DELETE | Remove | Yes | No |

### Status Codes
```
2xx Success
  200 OK - General success with body
  201 Created - Resource created (include Location header)
  204 No Content - Success, no body (DELETE, PUT)

4xx Client Error
  400 Bad Request - Validation failed
  401 Unauthorized - Not authenticated
  403 Forbidden - Not authorized
  404 Not Found - Resource doesn't exist
  409 Conflict - State conflict (duplicate, version mismatch)
  422 Unprocessable Entity - Semantic validation failed

5xx Server Error
  500 Internal Server Error - Unexpected error
  502 Bad Gateway - Upstream service failed
  503 Service Unavailable - Temporarily down
```

## Response Formats

### Success Response
```json
{
  "data": {
    "id": "123",
    "type": "user",
    "attributes": { ... }
  }
}
```

Or simpler:
```json
{
  "id": "123",
  "name": "Example",
  ...
}
```

Match what the codebase already uses.

### List Response
```json
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

## Versioning Strategies

### URL Versioning (Recommended)
```
/api/v1/resources
/api/v2/resources
```

### Header Versioning
```
Accept: application/vnd.api+json;version=1
```

### When to Version
- Breaking changes to response structure
- Removing fields
- Changing field types
- Removing endpoints

### Non-Breaking Changes (No Version Needed)
- Adding new fields
- Adding new endpoints
- Adding optional parameters

## GraphQL Considerations

### When to Use GraphQL
- Complex, nested data requirements
- Multiple clients with different data needs
- Rapid iteration on data shape
- Real-time subscriptions needed

### Schema Design
```graphql
type User {
  id: ID!
  email: String!
  orders(first: Int, after: String): OrderConnection!
}

type Query {
  user(id: ID!): User
  users(filter: UserFilter): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
}
```

### Best Practices
- Use input types for mutations
- Return payload types (not just the entity)
- Use connections for pagination
- Keep resolvers thin (business logic in services)

## Output Format

When designing an API, provide:

```markdown
## API Design: [Feature Name]

### Endpoints

#### Create Resource
- **Method**: POST
- **URL**: `/api/v1/resources`
- **Auth**: Required
- **Request Body**:
```json
{
  "name": "string (required)",
  "description": "string (optional)"
}
```
- **Response** (201):
```json
{
  "id": "string",
  "name": "string",
  "createdAt": "ISO8601"
}
```
- **Errors**:
  - 400: Invalid input
  - 401: Not authenticated
  - 409: Duplicate name

### Database Changes
- New table/columns needed
- Indexes for query patterns

### Notes
- Rate limiting considerations
- Caching strategy
- Future considerations
```

## Guidelines

- Follow existing patterns in the codebase first
- Design for the client's use case, not the database structure
- Use plural nouns for resources (`/users` not `/user`)
- Keep URLs lowercase with hyphens (`/order-items`)
- Don't expose internal IDs if possible (use UUIDs or slugs)
- Consider pagination from the start for list endpoints
- Document everything the client needs to know
