# Sandboxed Execution Pattern

This document describes when and how to use sandboxed execution for high-risk work.

## When to Use Sandboxed Execution

Use sandboxed execution when:
- Executing untrusted or third-party code
- Working with external dependencies that may have side effects
- Running tasks that could modify system state unexpectedly
- Testing code that interacts with network, filesystem, or system services
- Evaluating code from external sources (user submissions, plugins, etc.)

## Sandboxing Approaches

### 1. Docker Container Isolation

For maximum isolation, run high-risk work in a Docker container:

```bash
# Create a sandboxed execution environment
docker run --rm -it \
  --network none \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  -v $(pwd):/workspace:ro \
  -w /workspace \
  node:20-slim \
  npm test
```

**Flags explained:**
- `--network none`: No network access
- `--read-only`: Filesystem is read-only
- `--tmpfs /tmp`: Temporary writable space
- `--cap-drop ALL`: Drop all Linux capabilities
- `-v $(pwd):/workspace:ro`: Mount code read-only

### 2. Claude Code Sandbox Mode

Claude Code can be invoked with restricted permissions:

```bash
# Run with explicit denials
claude --deny-write --deny-bash "Review this code for security issues"
```

**Permission flags:**
- `--deny-write`: Prevent file modifications
- `--deny-bash`: Prevent shell command execution
- `--deny-network`: Prevent network access (if available)

### 3. Virtual Machine Isolation

For the highest security (e.g., malware analysis):
- Use a disposable VM
- Snapshot before execution
- Revert after execution
- Never expose host network or filesystem

## Security Boundaries

### What sandboxing protects against:
- Accidental file deletion or modification
- Network exfiltration of sensitive data
- System configuration changes
- Resource exhaustion (with proper limits)
- Privilege escalation (with capability dropping)

### What sandboxing does NOT protect against:
- Logic flaws in the sandboxed code itself
- Information leakage through timing channels
- Vulnerabilities in the container runtime
- Host kernel exploits (rare but possible)

## Escape Hatches

When sandboxed code needs specific permissions:

1. **Document the requirement** in the task file
2. **Get PO approval** before granting access
3. **Use minimum necessary permissions**
4. **Audit all actions** performed with elevated access

Example approval request:
```markdown
## Sandbox Escape Request

Task: TASK-042
Requirement: Write access to /config directory
Justification: Configuration file generation
Risk mitigation: Only .json files allowed, validated schema
PO Approval: [PENDING]
```

## Audit Trail Requirements

All sandboxed executions must log:
- Start time and end time
- Container/sandbox configuration used
- Files accessed or modified
- Network connections attempted
- Exit code and any errors
- SHA256 hash of any outputs

Example log format:
```json
{
  "execution_id": "SANDBOX-2026-01-11-001",
  "task_id": "TASK-042",
  "start_time": "2026-01-11T10:00:00Z",
  "end_time": "2026-01-11T10:05:23Z",
  "sandbox_type": "docker",
  "config": {
    "network": "none",
    "readonly": true,
    "capabilities": []
  },
  "files_modified": [],
  "exit_code": 0,
  "output_hash": "sha256:abc123..."
}
```

## Integration with Factory Protocol

### GO Gate
- Sandboxed execution still requires GO gate approval
- Task file must specify sandboxing requirements
- PO must approve sandbox configuration

### Reports
- Execution reports must note sandboxed status
- Include sandbox audit log reference
- Document any escape hatches used

### CI Validation
- CI can validate sandbox configurations exist for marked tasks
- High-risk tasks without sandbox requirements should warn

## Example: Sandboxed Test Execution

```bash
#!/bin/bash
# Run tests in isolated container

TASK_ID=$1
SANDBOX_LOG="docs/execution/sandbox-logs/${TASK_ID}.json"

# Create sandbox log directory
mkdir -p docs/execution/sandbox-logs

# Record start
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Run sandboxed tests
docker run --rm \
  --network none \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  -v $(pwd):/workspace:ro \
  -w /workspace \
  node:20-slim \
  npm test 2>&1 | tee /tmp/sandbox-output.txt

EXIT_CODE=$?
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
OUTPUT_HASH=$(sha256sum /tmp/sandbox-output.txt | cut -d' ' -f1)

# Write audit log
cat > "$SANDBOX_LOG" <<EOF
{
  "execution_id": "SANDBOX-$(date +%Y-%m-%d)-${TASK_ID}",
  "task_id": "${TASK_ID}",
  "start_time": "${START_TIME}",
  "end_time": "${END_TIME}",
  "sandbox_type": "docker",
  "exit_code": ${EXIT_CODE},
  "output_hash": "sha256:${OUTPUT_HASH}"
}
EOF

exit $EXIT_CODE
```

## Summary

| Risk Level | Sandbox Type | Use Case |
|------------|--------------|----------|
| Low | None | Trusted internal code |
| Medium | Claude Code restrictions | Code review, analysis |
| High | Docker container | Untrusted dependencies |
| Critical | Isolated VM | Malware, exploit testing |

When in doubt, use more isolation rather than less.
