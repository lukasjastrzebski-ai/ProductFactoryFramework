# Memory Setup (Claude Code)

This document explains how to enable and use session memory safely.

Memory improves continuity but NEVER overrides repository artifacts.

---

## Supported memory mechanism

Recommended:
- claude-mem plugin for Claude Code

Install:
1) /plugin marketplace add thedotmack/claude-mem
2) /plugin install claude-mem

---

## What memory stores

- files edited
- commands run
- decisions made
- tasks executed
- errors encountered

Memory is indexed and fetched selectively.

---

## What memory is NOT

- a source of truth
- a replacement for specs or plans
- an authority over files

---

## Usage guidance

Allowed queries:
- What did we do last session?
- Which tasks were completed recently?
- What commands failed last time?

Forbidden usage:
- inventing requirements
- bypassing specs
- skipping verification against files