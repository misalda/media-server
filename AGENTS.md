# AGENTS.md

## Build/Lint/Test Commands
- **Build**: No build system configured yet
- **Lint**: No linting configured yet
- **Test**: No tests configured yet
- **Run single test**: N/A

## Code Style Guidelines

### General
- Use TypeScript for type safety
- Follow semantic versioning for releases
- Document APIs with OpenAPI/Swagger

### Naming Conventions
- Use camelCase for variables and functions
- Use PascalCase for classes and interfaces
- Use UPPER_SNAKE_CASE for constants
- Use kebab-case for file names

### Imports
- Group imports: standard library, third-party, local
- Use absolute imports for internal modules
- Avoid wildcard imports

### Error Handling
- Use try/catch for async operations
- Return meaningful error messages
- Log errors with appropriate levels

### Types
- Prefer interfaces over types for object shapes
- Use union types for related variants
- Avoid `any` type; use `unknown` when necessary

### Formatting
- Use 2 spaces for indentation
- Max line length: 100 characters
- Trailing commas in multi-line structures