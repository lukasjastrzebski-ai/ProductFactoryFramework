# Phase 0: Assessment

**Time: 1-2 hours**

Phase 0 evaluates your existing project to determine migration scope and identify documentation gaps.

---

## Overview

Assessment answers three questions:
1. What does this project currently have?
2. What does the factory require?
3. What's the gap, and how do we close it?

---

## Step 1: Inventory Existing Documentation

Locate and catalog all existing documentation:

### Documentation Types to Find

| Type | Common Locations | Priority |
|------|------------------|----------|
| README files | Root, subdirectories | High |
| Architecture docs | /docs, /architecture, wiki | High |
| API documentation | /docs/api, OpenAPI specs | Medium |
| Feature descriptions | Issues, PRs, wikis | Medium |
| Decision records | /docs/decisions, /adr | Medium |
| Test documentation | /tests, /docs/testing | Medium |
| Deployment guides | /docs, /deploy, CI configs | Low |
| User guides | /docs, wiki | Low |

### Commands to Discover Documentation

```bash
# Find all markdown files
find . -name "*.md" -type f | head -50

# Find documentation directories
find . -type d -name "doc*" -o -name "wiki" -o -name "adr"

# Find README files
find . -name "README*" -type f

# Check for OpenAPI/Swagger specs
find . -name "*.yaml" -o -name "*.yml" | xargs grep -l "openapi\|swagger" 2>/dev/null
```

### Document Your Findings

Use the [Migration Assessment Template](templates/migration_assessment.md) to record:
- Files found
- Completeness rating (1-5)
- Relevance to migration

---

## Step 2: Catalog Features

Identify all features in the system:

### Feature Discovery Methods

1. **README examination** - Look for feature lists
2. **Route/endpoint analysis** - Each major route often = feature
3. **UI inspection** - Major screens/workflows = features
4. **Issue tracker review** - Completed feature issues
5. **Test file analysis** - Test files often map to features

### Commands for Feature Discovery

```bash
# List route files (web frameworks)
find . -name "*route*" -o -name "*controller*" -o -name "*handler*"

# Find component directories (React/Vue/etc)
find . -type d -name "components" | head -5

# List API endpoints from tests
grep -r "describe\|test\|it\(" tests/ | grep -i "endpoint\|api\|route"

# Find feature flags
grep -r "feature\|flag\|toggle" --include="*.json" --include="*.yaml"
```

### Categorize Features

For each feature identified, classify as:

| Category | Definition | Documentation Priority |
|----------|------------|----------------------|
| **MVP** | Core functionality, product would fail without it | Must document |
| **Critical** | Important functionality, significant user impact | Should document |
| **Secondary** | Nice-to-have, limited user impact | May document |
| **Deprecated** | Planned for removal | Do not document |

### Feature Catalog Format

```markdown
| Feature ID | Name | Category | Has Tests | Has Docs | Notes |
|------------|------|----------|-----------|----------|-------|
| FEAT-001 | User Auth | MVP | Yes | Partial | Login, signup, password reset |
| FEAT-002 | Dashboard | MVP | Partial | No | Main user interface |
| FEAT-003 | Reports | Critical | No | No | PDF export feature |
```

---

## Step 3: Map Architecture Components

Document the system architecture as it actually exists:

### Components to Identify

| Component Type | Questions to Answer |
|----------------|---------------------|
| **Frontend** | Framework? Build tools? State management? |
| **Backend** | Language? Framework? Structure pattern? |
| **Database** | Type? Schema management? Migrations? |
| **External Services** | APIs? Third-party integrations? |
| **Infrastructure** | Hosting? CI/CD? Deployment? |

### Commands for Architecture Discovery

```bash
# Check for package files
ls package.json requirements.txt Gemfile go.mod Cargo.toml pom.xml 2>/dev/null

# Identify framework from dependencies
cat package.json | grep -E "react|vue|angular|express|nest|next"
cat requirements.txt | grep -E "django|flask|fastapi" 2>/dev/null

# Find database configurations
find . -name "*.env*" -o -name "database.*" -o -name "*db*config*"

# Check for Docker/container setup
ls Dockerfile docker-compose.yml 2>/dev/null

# Review CI configuration
ls .github/workflows/*.yml .gitlab-ci.yml Jenkinsfile 2>/dev/null
```

### Architecture Diagram

Create a simple component diagram:

```
┌─────────────────────────────────────────────────────────┐
│                    Your System                          │
├─────────────────────────────────────────────────────────┤
│  Frontend: [framework] @ [version]                      │
│  Backend: [framework] @ [version]                       │
│  Database: [type] @ [version]                           │
│  External: [services list]                              │
│  Infra: [hosting provider]                              │
└─────────────────────────────────────────────────────────┘
```

---

## Step 4: Assess Test Coverage

Measure current test coverage to establish baseline:

### Coverage Measurement Commands

```bash
# JavaScript/TypeScript (Jest)
npm test -- --coverage --coverageReporters=text-summary

# JavaScript/TypeScript (Vitest)
npx vitest run --coverage

# Python (pytest)
pytest --cov=. --cov-report=term-missing

# Go
go test -cover ./...

# Ruby
bundle exec rspec --format documentation
bundle exec rails test

# Java (Maven)
mvn test jacoco:report
```

### Test Inventory

| Test Type | Count | Passing | Failing | Coverage |
|-----------|-------|---------|---------|----------|
| Unit | | | | |
| Integration | | | | |
| E2E | | | | |
| Manual/QA | | | | |

### Quality Metrics to Record

- **Line coverage**: X%
- **Branch coverage**: X% (if available)
- **Flaky tests**: Count of intermittently failing tests
- **Build time**: Average test suite duration
- **Last green build**: Date of last successful CI run

---

## Step 5: Identify Stakeholders

Document who knows what about the system:

### Stakeholder Types

| Role | Knowledge Area | Contact |
|------|----------------|---------|
| Original Author | Architecture, history | |
| Active Maintainer | Current state, recent changes | |
| Domain Expert | Business logic, requirements | |
| DevOps/SRE | Deployment, infrastructure | |
| Product Owner | Features, priorities | |

### Questions for Stakeholders

1. What are the most critical features?
2. What architecture decisions were made, and why?
3. What technical debt exists?
4. What's the deployment process?
5. What would you change if starting over?

---

## Step 6: Migration Scope Decision

Based on assessment findings, choose your migration scope:

### Decision Matrix

| Factor | Minimal | Standard | Full |
|--------|---------|----------|------|
| Features count | < 5 | 5-15 | > 15 |
| Team size | 1-2 | 2-5 | > 5 |
| Regulatory requirements | None | Some | Strict |
| Test coverage | Any | > 30% | > 60% |
| Documentation exists | None | Partial | Substantial |
| Available time | < 5 hours | 5-8 hours | > 8 hours |

### Scope Recommendation Logic

```
IF regulatory_requirements = "Strict" THEN scope = "Full"
ELSE IF features > 15 OR team_size > 5 THEN scope = "Full"
ELSE IF features > 5 OR test_coverage > 30% THEN scope = "Standard"
ELSE scope = "Minimal"
```

Record your decision in the assessment template.

---

## Exit Criteria Checklist

Before proceeding to Phase 1, verify:

- [ ] **Documentation inventory complete** - All existing docs cataloged
- [ ] **Feature catalog created** - All features identified and categorized
- [ ] **Architecture mapped** - Components and technologies documented
- [ ] **Test coverage measured** - Current metrics recorded
- [ ] **Stakeholders identified** - Key contacts documented
- [ ] **Scope decided** - Minimal, Standard, or Full chosen
- [ ] **Assessment template filled** - [Migration Assessment](templates/migration_assessment.md) complete

---

## Common Issues

### "Can't determine what's MVP"

Ask: "If this feature broke in production right now, would we wake someone up?"
- Yes → MVP
- No → Not MVP

### "Test coverage command doesn't work"

Check:
1. Test framework installed correctly
2. Tests actually exist
3. Coverage tool configured

If no test infrastructure exists, record coverage as 0% and proceed.

### "Too many features to document"

For large projects:
1. Document MVP features only (Minimal scope)
2. Group related features into feature families
3. Create one spec per family, not per feature

### "Nobody knows the architecture"

Document what you can observe from code:
1. Read package files for dependencies
2. Trace a request through the code
3. Examine the database schema
4. Review CI/CD configurations

---

## Next Step

Proceed to [Phase 1: Structure](phase_1_structure.md)
