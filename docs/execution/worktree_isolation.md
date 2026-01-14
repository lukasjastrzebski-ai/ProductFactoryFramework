# Worktree Isolation

**Version:** 20.0

This document describes git worktree isolation for parallel Task Agent execution.

---

## Overview

Each Task Agent operates in an isolated git worktree to prevent conflicts during parallel execution. Worktrees provide full repository access while maintaining separate working directories and branches.

---

## Worktree Structure

```
ProductFactoryFramework/          # Main repository
├── .git/                         # Git directory
├── src/
├── docs/
└── ...

../worktrees/                     # Worktrees directory (outside main repo)
├── agent-a1b2c3d4-TASK-001/     # Agent 1 worktree
│   ├── src/
│   ├── docs/
│   └── ...
├── agent-e5f6g7h8-TASK-002/     # Agent 2 worktree
│   ├── src/
│   ├── docs/
│   └── ...
└── ...
```

---

## Isolation Benefits

### File Isolation

- Each agent has its own working directory
- Changes don't affect other agents
- No merge conflicts during work

### Branch Isolation

- Each agent works on a dedicated branch
- Branches can be reviewed independently
- PO controls merge order

### Context Isolation

- Each agent has independent context
- No context pollution between tasks
- Fresh state for each task

---

## Worktree Management

### Create Worktree

```bash
./scripts/agents/worktree_manager.sh create \
    --agent agent-a1b2c3d4 \
    --task TASK-001
```

Creates:
- Directory: `../worktrees/agent-a1b2c3d4-TASK-001/`
- Branch: `agent/agent-a1b2c3d4/TASK-001`

### List Worktrees

```bash
./scripts/agents/worktree_manager.sh list
```

### Remove Worktree

```bash
./scripts/agents/worktree_manager.sh remove \
    --path ../worktrees/agent-a1b2c3d4-TASK-001
```

### Cleanup Stale Worktrees

```bash
./scripts/agents/worktree_manager.sh cleanup --force
```

---

## Branch Naming Convention

```
agent/{agent-id}/{task-id}
```

Examples:
- `agent/agent-a1b2c3d4/TASK-001`
- `agent/agent-e5f6g7h8/TASK-002`

---

## File Ownership Rules

### During Parallel Execution

1. **Exclusive Ownership** - Only one agent can modify a file at a time
2. **Dependency Analysis** - PO assigns tasks to avoid conflicts
3. **Conflict Detection** - PO monitors for unexpected conflicts

### File Ownership Table

| File | Owner | Task | Status |
|------|-------|------|--------|
| src/login.ts | agent-a1b2c3d4 | TASK-001 | active |
| src/dashboard.ts | agent-e5f6g7h8 | TASK-002 | active |
| src/utils.ts | (shared) | - | read-only |

### Shared Files

Files that multiple tasks might need:
- Can be read by any agent
- Must not be modified without coordination
- PO tracks shared file access

---

## Merge Process

### After Task Completion

1. Agent completes task and receives NEXT
2. Agent's worktree branch marked ready for merge
3. PO determines safe merge order
4. PO merges branch to main
5. Worktree cleaned up

### Merge Order

PO determines merge order based on:
- Dependency graph
- File modification overlap
- Completion order

### Conflict Resolution

If merge conflict detected:

1. PO identifies conflicting files
2. PO determines which agent's changes take precedence
3. Manual resolution if needed
4. Both agents may need to re-test after merge

---

## Cleanup Protocol

### Automatic Cleanup

After successful merge:

```bash
./scripts/agents/worktree_manager.sh remove \
    --path ../worktrees/agent-a1b2c3d4-TASK-001
git branch -d agent/agent-a1b2c3d4/TASK-001
```

### Manual Cleanup

For failed/blocked agents:

```bash
./scripts/agents/worktree_manager.sh cleanup --force
```

### Orphaned Worktrees

Detected when:
- Agent registry shows completed/blocked
- Worktree still exists

Handled by cleanup command.

---

## Disk Space Management

### Worktree Size

Each worktree is approximately the size of the repository.

### Monitoring

```bash
./scripts/agents/worktree_manager.sh status
```

Shows:
- Active worktrees
- Disk usage
- Orphaned worktrees

### Best Practices

1. Clean up completed worktrees promptly
2. Run cleanup before spawning new agents if space is limited
3. Monitor worktree count

---

## Security Considerations

### Worktree Location

Place worktrees outside main repository:
- Prevents accidental commits to main
- Easier to clean up
- Clear separation

### Access Control

- Worktrees have same access as main repo
- Agent can read all files
- Agent should only write authorized files

### Sensitive Files

- `.env` files not committed
- Credentials not in worktrees
- Secrets handled separately

---

## Troubleshooting

### Worktree Creation Fails

```
error: failed to create worktree
```

Solutions:
1. Check if branch already exists
2. Clean up existing worktree
3. Verify git repository is clean

### Cannot Remove Worktree

```
error: cannot remove worktree with modified changes
```

Solutions:
1. Use `--force` flag
2. Manually delete directory
3. Check for uncommitted changes

### Branch Conflicts

```
error: branch already exists
```

Solutions:
1. Use different agent ID
2. Delete existing branch
3. Check for incomplete previous spawn

---

## Related Documentation

- [Agent Spawning](agent_spawning.md)
- [Task Assignment](task_assignment.md)
- [Agent Registry](agent_registry.md)
