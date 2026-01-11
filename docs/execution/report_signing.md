# Report Signing

This document describes the cryptographic integrity verification system for execution reports.

## Purpose

Report signing provides:
- **Integrity verification**: Detect if reports have been modified after completion
- **Audit trail**: Timestamp when reports were finalized
- **Non-repudiation**: Evidence that a report existed in a specific state

## How It Works

Reports are signed using SHA256 checksums. When a report is signed:
1. A SHA256 hash of the report content is computed
2. The hash is stored in `docs/execution/signatures/<TASK-ID>.sha256`
3. Verification compares the stored hash against the current file hash

## Usage

### Sign a Single Report

```bash
./tools/sign_report.sh sign docs/execution/reports/TASK-001.md
```

### Sign All Unsigned Reports

```bash
./tools/sign_report.sh sign-all
```

### Verify a Report

```bash
./tools/sign_report.sh verify TASK-001.md
```

### Verify All Reports

```bash
./tools/sign_report.sh verify-all
```

### List Report Status

```bash
./tools/sign_report.sh list
```

## Signature File Format

Signature files are stored in `docs/execution/signatures/` with the format:

```
# Report Signature
# Generated: 2026-01-11T10:00:00Z
# File: docs/execution/reports/TASK-001.md
abc123def456...  TASK-001.md
```

## Workflow Integration

### After Task Completion

1. Write the execution report to `docs/execution/reports/TASK-XXX.md`
2. Sign the report: `./tools/sign_report.sh sign TASK-XXX.md`
3. Commit both the report and signature file

### Before NEXT Gate

The PO can verify report integrity before approving:
```bash
./tools/sign_report.sh verify TASK-XXX.md
```

### CI Validation

CI can optionally validate all COMPLETE task reports have valid signatures.

## Security Considerations

### What This Provides
- Detection of accidental modifications
- Evidence of report state at signing time
- Simple, auditable process

### What This Does NOT Provide
- Authentication (anyone can sign)
- Protection against intentional tampering by someone with repo access
- Legal non-repudiation

### For Stronger Guarantees

For higher security requirements:
1. Use GPG signing with personal keys
2. Store signatures in a separate, write-protected location
3. Use a trusted timestamping service

## GPG Signing (Optional)

For stronger cryptographic guarantees, use GPG:

```bash
# Sign with GPG
gpg --armor --detach-sign docs/execution/reports/TASK-001.md

# Verify
gpg --verify docs/execution/reports/TASK-001.md.asc
```

## Troubleshooting

### "MODIFIED" Status

The report was changed after signing. Options:
1. Review the changes to ensure they're intentional
2. Re-sign: `./tools/sign_report.sh sign TASK-XXX.md`

### "UNSIGNED" Status

The report has never been signed. Sign it with:
```bash
./tools/sign_report.sh sign TASK-XXX.md
```

### Hash Mismatch

If verification fails with a hash mismatch:
1. Check if the report was legitimately updated
2. Check for whitespace or encoding changes
3. If the update is valid, re-sign the report
