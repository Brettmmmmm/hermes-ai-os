# Policy Layers

Every Hermes skill invocation passes through three deterministic policy gates.

## 1. Format Policy

Enforces output structure. Every skill declares its expected sections:

```yaml
policy:
  format: markdown
  structure:
    - "Symptoms"
    - "Root Cause"
    - "Evidence"
    - "Remediation"
```

The runtime validates that every heading in the structure list is present before returning.

## 2. Safety Policy

Controls temperature, retries, and content filtering:

| Safety Level | Temperature | Retries | Content Filter |
|--------------|-------------|---------|----------------|
| `standard` | 0.2 | 2 | None |
| `strict` | 0.0 | 3 | Keyword + regex |
| `research` | 0.3 | 1 | None |

Applied via execution profiles (`fast.yaml`, `deep.yaml`, `secure.yaml`).

## 3. Reproducibility Policy

Ensures the same input always produces the same output structure:

- **Deterministic seeds** per profile
- **Pinned model versions** in config (no floating tags in production)
- **Cache layer** for identical requests
- **Idempotency checks** on skill packs

## Enforcement Order

```
Input → Format Policy → Safety Policy → Model → Reproducibility Policy → Output
```
