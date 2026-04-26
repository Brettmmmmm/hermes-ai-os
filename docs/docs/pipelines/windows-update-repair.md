# Windows Update Repair Pipeline

This pipeline is a deterministic, AI-driven workflow that orchestrates:

1. **Diagnostics**  
   Uses the `diagnostics` skill (analyst + kimi-k2.5:cloud) to identify symptoms, evidence, and root cause.

2. **Remediation Planning**  
   Uses the `windows-update-repair` skill pack (operator) to generate a structured plan.

3. **Script Generation**  
   Uses the `codegen` skill (coder + deepseek-r1) to produce a complete PowerShell script.

4. **Execution & Verification**  
   Runs the script, then re-invokes diagnostics to confirm resolution.

## Deterministic Output Format

Every invocation produces:

- Goal
- Diagnostics Summary
- Root Cause
- Remediation Plan
- PowerShell Script
- Verification Steps
- Post-Checks
