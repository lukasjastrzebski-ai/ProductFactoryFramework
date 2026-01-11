# Language and Framework Guidance for Claude Code

Based on industry research on optimal language choices for AI-assisted development.

---

## Overview

Different programming languages and frameworks interact with AI coding assistants in varying ways. This guide helps select technologies that work well with Claude Code.

---

## Language Recommendations

### Tier 1: Optimal for Claude Code

These languages have characteristics that align well with AI-assisted development:

#### Go

**Strengths:**
- Simple, explicit syntax
- Excellent error messages
- Fast compilation and tooling
- Strong standard library
- Minimal magic or hidden behavior

**Best For:**
- Backend services
- CLI tools
- Infrastructure code

#### Python

**Strengths:**
- Familiar patterns
- Extensive libraries
- Clear, readable syntax
- Strong typing available (type hints)
- Excellent documentation

**Best For:**
- Data processing
- Scripts and automation
- API backends (FastAPI, Flask)

#### TypeScript

**Strengths:**
- Type safety catches errors early
- Excellent IDE support
- Explicit contracts via interfaces
- Modern JavaScript features
- Large ecosystem

**Best For:**
- Frontend applications
- Node.js backends
- Full-stack development

---

### Tier 2: Good Support

These languages work well but have some characteristics that require extra care:

#### Rust

**Strengths:**
- Strong type system
- Memory safety
- Excellent error messages

**Challenges:**
- Complex borrowing rules
- Steep learning curve
- Verbose for simple tasks

#### JavaScript

**Strengths:**
- Flexible and dynamic
- Huge ecosystem
- Fast iteration

**Challenges:**
- Type ambiguity
- Runtime errors
- Implicit coercion

#### Java

**Strengths:**
- Clear OOP patterns
- Strong typing
- Mature ecosystem

**Challenges:**
- Verbose syntax
- Heavy frameworks
- Boilerplate code

---

## Framework Recommendations

### Backend Frameworks

#### Recommended

| Language | Framework | Why |
|----------|-----------|-----|
| Go | Standard library / Chi | Explicit, minimal magic |
| Python | FastAPI | Clear routing, type hints |
| TypeScript | Express / Fastify | Simple, well-documented |

#### Avoid

- Heavy ORM abstractions that hide SQL
- Frameworks with extensive runtime reflection
- Frameworks that generate code

### Frontend Frameworks

#### Recommended

| Framework | Why |
|-----------|-----|
| React + TypeScript | Best supported, explicit data flow |
| Vue 3 + TypeScript | Clear component model |
| Svelte | Explicit reactivity |

#### Considerations

- Prefer composition over inheritance
- Avoid complex state management until needed
- Keep component hierarchies shallow

---

## Anti-Patterns to Avoid

### Meta-Programming

**Problem:** Code that writes code is hard for AI to reason about.

**Examples:**
- Heavy use of decorators that modify behavior
- Runtime class generation
- Macro-heavy systems

**Alternative:** Explicit, straightforward code

### Dynamic Typing in Critical Paths

**Problem:** Type ambiguity leads to incorrect assumptions.

**Examples:**
- Untyped function parameters
- Dynamic object shapes
- Duck typing without interfaces

**Alternative:** Use type hints, interfaces, or typed languages

### Frameworks That Generate Code

**Problem:** Generated code is hard to understand and modify.

**Examples:**
- Scaffolding that creates many files
- Code-first ORMs that generate schema
- Template engines with complex logic

**Alternative:** Write code explicitly, use minimal generation

### Complex DI Containers

**Problem:** Dependency injection containers hide object creation.

**Examples:**
- Auto-wiring based on types
- XML/YAML configuration
- Runtime binding

**Alternative:** Constructor injection, explicit factories

---

## Best Practices

### 1. Explicit Over Implicit

```typescript
// Good: Explicit
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Avoid: Implicit magic
@Computed()
total() { /* framework magic */ }
```

### 2. Clear Error Messages

Choose tools with helpful error output:
- TypeScript compiler errors
- Go build errors
- Rust compiler suggestions

### 3. Fast Feedback Loops

Prefer technologies with:
- Fast compilation
- Hot reload
- Quick test execution

### 4. Minimal Configuration

Less config = less ambiguity:
- Convention over configuration is OK
- Magic configuration is not
- Explicit config files are best

---

## Project Setup Recommendations

### TypeScript Project

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true
  }
}
```

### Python Project

```toml
# pyproject.toml
[tool.mypy]
strict = true
```

### Go Project

Standard Go modules with explicit dependencies.

---

## Summary

| Characteristic | Recommended | Avoid |
|---------------|-------------|-------|
| Typing | Strong, static | Weak, dynamic |
| Syntax | Explicit | Magic/implicit |
| Error messages | Clear, actionable | Vague, unhelpful |
| Tooling | Fast, integrated | Slow, fragmented |
| Configuration | Minimal, explicit | Heavy, magical |

When in doubt, choose the simpler, more explicit option. Claude Code works best with code that does what it appears to do.
