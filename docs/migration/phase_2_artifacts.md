# Phase 2: Artifact Creation

**Time: 2-4 hours** (scales with project size)

Phase 2 creates retroactive specifications for your existing features and architecture.

---

## Overview

This is the most substantial phase. You will document:
- Product context in docs/ai.md
- Feature specifications
- Architecture documentation
- Architecture Decision Records (ADRs)

Remember: **Document what EXISTS, not what you wish existed.**

---

## Priority Order

Complete artifacts in this order:

| Priority | Artifact | Required For |
|----------|----------|--------------|
| 1 | docs/ai.md | Factory operation |
| 2 | specs/features/index.md | Feature overview |
| 3 | MVP feature specs | Core documentation |
| 4 | architecture/system.md | System understanding |
| 5 | Retroactive ADRs | Decision history |
| 6 | Secondary feature specs | Full adoption only |

---

## Step 1: Fill docs/ai.md Product Context

The AI contract requires product context. Fill the placeholders:

### Before (Template)

```markdown
## Product Context

Product: {{PRODUCT_NAME}}
Core Problem: {{CORE_PROBLEM}}
Target User: {{TARGET_USER}}
```

### After (Example)

```markdown
## Product Context

Product: Acme Dashboard
Core Problem: Teams lack visibility into deployment status across multiple environments
Target User: DevOps engineers and platform teams managing multi-environment deployments
```

### Guidelines for Product Context

| Field | Good Example | Bad Example |
|-------|--------------|-------------|
| Product | "Acme Dashboard" | "Dashboard" (too generic) |
| Core Problem | "Teams lack visibility into deployment status" | "Better deployments" (vague) |
| Target User | "DevOps engineers managing multi-environment deployments" | "Anyone" (too broad) |

### Migration-Specific Addition

Add a migration note to docs/ai.md:

```markdown
## Migration Note

This project was migrated to the Product Factory Framework on [DATE].
Pre-migration code exists and is documented retroactively.
Quality baseline established from existing state, not ideal state.
```

---

## Step 2: Create Feature Index

Create `specs/features/index.md`:

```markdown
# Feature Index

Last updated: YYYY-MM-DD

## MVP Features

| ID | Name | Status | Spec | Test Plan |
|----|------|--------|------|-----------|
| FEAT-001 | User Authentication | Implemented | [Link](user_auth.md) | [Link](../tests/feature_user_auth_test_plan.md) |
| FEAT-002 | Dashboard | Implemented | [Link](dashboard.md) | [Link](../tests/feature_dashboard_test_plan.md) |
| FEAT-003 | Notifications | Implemented | [Link](notifications.md) | Pending |

## Secondary Features

| ID | Name | Status | Spec | Test Plan |
|----|------|--------|------|-----------|
| FEAT-010 | Dark Mode | Implemented | Pending | N/A |
| FEAT-011 | Export to PDF | Implemented | Pending | N/A |

## Deprecated Features

| ID | Name | Status | Notes |
|----|------|--------|-------|
| FEAT-090 | Legacy Reports | Deprecated | Replaced by FEAT-003 |

## Feature Count Summary

- MVP: 3
- Secondary: 2
- Deprecated: 1
- Total Active: 5
```

### Status Values

| Status | Meaning |
|--------|---------|
| Implemented | Feature exists and works |
| Partial | Feature exists but incomplete |
| Planned | Feature planned, not built |
| Deprecated | Feature being removed |

---

## Step 3: Document MVP Features

For each MVP feature, create a specification using [existing_feature_spec.md](templates/existing_feature_spec.md).

### Time Estimates by Feature Complexity

| Complexity | Time per Feature | Characteristics |
|------------|------------------|-----------------|
| Simple | 10-15 minutes | Single screen, few interactions |
| Medium | 20-30 minutes | Multiple screens, some integrations |
| Complex | 45-60 minutes | Many components, external integrations |

### Example: Documenting User Authentication

Create `specs/features/user_auth.md`:

```markdown
# Feature Specification: User Authentication

Feature ID: FEAT-001
Name: User Authentication
Status: Implemented

## Problem

Users need secure access to the system with their credentials.

## Description

The authentication system provides login, signup, password reset, and session management functionality.

Current implementation uses JWT tokens with refresh mechanism.

## User Stories

- As a new user, I want to create an account so that I can access the system
- As a returning user, I want to log in with my credentials so that I can resume my work
- As a user who forgot my password, I want to reset it so that I can regain access

## Acceptance Criteria

- [x] User can create account with email and password
- [x] User can log in with valid credentials
- [x] User receives error message for invalid credentials
- [x] User can request password reset email
- [x] User can reset password via email link
- [x] Session expires after 24 hours of inactivity
- [x] JWT tokens are refreshed automatically

Note: Criteria marked [x] are verified as implemented.

## Non-Goals

- Social login (OAuth) - not implemented
- Multi-factor authentication - not implemented
- SSO integration - not implemented

## Dependencies

- PostgreSQL database (user storage)
- SendGrid API (password reset emails)
- JWT library (jsonwebtoken)

## Implementation Notes

- Login endpoint: POST /api/auth/login
- Signup endpoint: POST /api/auth/signup
- Reset endpoint: POST /api/auth/reset-password
- Token refresh: POST /api/auth/refresh

## Open Questions

None - feature is stable and fully implemented.
```

### Tips for Retroactive Specifications

1. **Check acceptance criteria that are actually implemented** - Don't leave them unchecked
2. **Include implementation notes** - Endpoints, file locations, key code paths
3. **Document what's NOT implemented in Non-Goals** - This prevents scope creep
4. **Reference actual code** - Link to files or functions where possible

---

## Step 4: Create Architecture Documentation

Create `architecture/system.md`:

```markdown
# System Architecture

Last updated: YYYY-MM-DD

## Overview

[2-3 sentence description of the system]

## Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        System Name                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Frontend   │───▶│   Backend    │───▶│   Database   │  │
│  │  (React)     │    │  (Node.js)   │    │  (Postgres)  │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         │                   │                              │
│         │                   ▼                              │
│         │           ┌──────────────┐                       │
│         └──────────▶│  External    │                       │
│                     │  Services    │                       │
│                     └──────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| Frontend | React | 18.x | User interface |
| Backend | Node.js/Express | 18.x/4.x | API server |
| Database | PostgreSQL | 14.x | Data persistence |
| Cache | Redis | 7.x | Session storage |
| Queue | Bull | 4.x | Background jobs |

## Key Architectural Patterns

### Pattern 1: [Name]

[Description of the pattern and why it's used]

### Pattern 2: [Name]

[Description]

## Data Flow

1. User request arrives at frontend
2. Frontend calls backend API
3. Backend validates request and processes
4. Backend queries/updates database
5. Response returns through stack

## External Integrations

| Service | Purpose | Authentication |
|---------|---------|----------------|
| SendGrid | Email | API Key |
| Stripe | Payments | API Key + Webhook |
| S3 | File storage | IAM Role |

## Deployment Architecture

- Hosting: [AWS/GCP/Vercel/etc.]
- CI/CD: [GitHub Actions/Jenkins/etc.]
- Environments: [dev, staging, prod]

## Security Considerations

- Authentication: JWT with refresh tokens
- Authorization: Role-based access control
- Data: Encrypted at rest and in transit
- Secrets: Managed via [Vault/env vars/etc.]

## Known Limitations

- [List any known architectural limitations]
- [Performance constraints]
- [Scale limitations]
```

---

## Step 5: Write Retroactive ADRs

Document significant architecture decisions using [retroactive_adr.md](templates/retroactive_adr.md).

### What Deserves an ADR?

| Write ADR | Skip ADR |
|-----------|----------|
| Database choice | Linting rules |
| Framework selection | Individual library choice |
| Authentication approach | CSS methodology |
| API design patterns | Test file organization |
| Deployment strategy | Variable naming |

### Example: Retroactive ADR

Create `architecture/decisions/ADR-0001-postgresql-database.md`:

```markdown
# ADR-0001: PostgreSQL as Primary Database

Status: Accepted (retroactive)
Date: Original decision ~2023-06, documented 2024-01

## Context

The application needed a relational database for storing user data, application state, and transactional records.

## Decision

PostgreSQL was chosen as the primary database.

## Alternatives Considered

1. **MySQL** - Rejected; team had more PostgreSQL experience
2. **MongoDB** - Rejected; data model is relational, not document-oriented
3. **SQLite** - Rejected; insufficient for production scale

## Consequences

### Positive

- Strong ACID compliance for transactional data
- Excellent JSON support for semi-structured data
- Mature tooling and ecosystem
- Team expertise reduces learning curve

### Negative

- Requires managed service for production (cost)
- Horizontal scaling more complex than NoSQL

## Notes

This ADR was created retroactively during factory migration.
The original decision was made informally at project start.
Rationale reconstructed from team discussions.
```

### ADR Naming Convention

```
ADR-XXXX-short-description.md

Examples:
ADR-0001-postgresql-database.md
ADR-0002-jwt-authentication.md
ADR-0003-react-frontend.md
ADR-0004-monorepo-structure.md
```

---

## Time Estimates by Project Size

| Project Size | Features | Artifacts | Estimated Time |
|--------------|----------|-----------|----------------|
| Small | 1-5 | ai.md, index, 3 specs, system.md | 2-3 hours |
| Medium | 5-15 | ai.md, index, 8 specs, system.md, 3 ADRs | 3-5 hours |
| Large | 15+ | ai.md, index, 15+ specs, system.md, 5+ ADRs | 5-8 hours |

---

## Exit Criteria Checklist

Before proceeding to Phase 3, verify:

### Minimal Adoption

- [ ] docs/ai.md populated with product context
- [ ] specs/features/index.md created
- [ ] MVP features listed in index
- [ ] architecture/system.md created

### Standard Adoption

All of Minimal, plus:
- [ ] MVP feature specifications created (all)
- [ ] At least 2-3 major ADRs written
- [ ] Feature test plans referenced (if tests exist)

### Full Adoption

All of Standard, plus:
- [ ] Secondary feature specifications created
- [ ] Comprehensive ADR coverage
- [ ] All feature test plans documented

---

## Common Issues

### "I don't know why a decision was made"

Write ADR with:
- Context: What you can observe
- Decision: What was chosen
- Rationale: "Unknown - reconstructed from code"

This is acceptable for retroactive documentation.

### "Feature has changed many times"

Document current behavior:
- Current state as acceptance criteria
- Historical notes in Implementation Notes section
- Don't document every iteration

### "Some features overlap"

Options:
1. Document as one combined feature
2. Document separately with cross-references
3. Use "Related Features" section

### "Tests don't match feature boundaries"

This is common. Document what exists:
- List tests that cover the feature
- Note gaps in test coverage
- Create test plan for future (in Phase 3)

---

## Next Step

Proceed to [Phase 3: Quality](phase_3_quality.md)
