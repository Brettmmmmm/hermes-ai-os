# Getting Started with Hermes AI OS

This guide walks you through setting up Hermes AI OS from scratch — configuration, models, personalities, and running your first skill.

## Prerequisites

- **Git** installed and configured
- **Ollama** running with cloud models available (`ollama serve`)
- Python 3.9+ (for YAML validation)
- Node.js 18+ (for Docusaurus documentation)
- Optional: **OpenAI API key** for cloud fallback

### Verify Ollama

```bash
ollama list
# Should show available models. If empty, pull models:
ollama pull deepseek-v4-pro:cloud
ollama pull kimi-k2.6:cloud
ollama pull qwen3.5:cloud
```

## Step 1: Clone the Repository

```bash
git clone git@github.com:btfmo/hermes-ai-os.git
cd hermes-ai-os
```

## Step 2: Understand the Structure

```
hermes-ai-os/
├── config/hermes/
│   ├── config.yaml        ← Main config: models, routing, includes
│   ├── personalities/     ← 7 personality definitions
│   └── skills/            ← 8 skill definitions
├── docs/                  ← Docusaurus documentation
├── diagrams/              ← Architecture diagrams
└── VISION.md              ← Master vision & execution plan
```

## Step 3: Validate Configuration

```bash
# Install yamllint
pip install yamllint

# Validate all YAML configs
yamllint config/hermes
yamllint tools/skill-packs

# All should pass with no errors
```

## Step 4: Explore the Configuration

### Model Registry

Open `config/hermes/config.yaml`. You'll find all available models defined under `models:` with their provider, temperature, and token limits. The default model is `deepseek-v4-pro:cloud`.

### Skill Routing

The `routing:` section maps each skill to a specific model. This ensures:
- Architecture tasks use the strongest reasoning model (DeepSeek v4)
- Operational tasks use the reliable workhorse (Kimi K2.6)
- Fast tasks use the efficient model (Qwen 3.5)

### Personalities

Each file in `config/hermes/personalities/` defines a personality with an ID, name, description, system prompt, and default model.

### Skills

Each file in `config/hermes/skills/` defines a skill with an ID, description, personality reference, model, and enforced output policy.

## Step 5: Run Your First Skill (Conceptual)

The `hermes` CLI is currently a planned component. Until it's built, skills are invoked through whatever Hermes runtime you have configured (CLI agent, Telegram bot, or direct model interaction).

The conceptual invocation:

```bash
# Basic diagnostics
hermes run --skill diagnostics \
  --input '{"system_state":"Service X failing", "logs":"Connection refused on port 5432"}'

# Enterprise architecture
hermes run --skill enterprise-architecture \
  --input '{"task":"adr","title":"Database Migration Strategy","context":"PostgreSQL 14 to 16"}'

# VoxFlow health check
hermes run --skill voxflow-operations \
  --input '{"task":"health-check"}'
```

## Step 6: Browse the Documentation

```bash
cd docs
npm install
npm run start
# Opens http://localhost:3000 with full documentation
```

## Step 7: Add Your Own Personality

Create `config/hermes/personalities/my-role.yaml`:

```yaml
id: my-role
name: "My Role"
description: "What this personality does"
system_prompt: |
  You are a specialized AI that...
model: qwen3.5:cloud
```

Then add a skill that uses it in `config/hermes/skills/`.

## Step 8: Add a Domain Skill

Create `config/hermes/skills/my-domain.yaml`:

```yaml
id: my-domain
description: "What this skill accomplishes"
personality: analyst
model: ollama:kimi-k2.6:cloud
policy:
  format: "markdown"
  structure:
    - "Context"
    - "Analysis"
    - "Recommendation"
```

Add a routing entry in `config/hermes/config.yaml` under `routing:`.

## Next Steps

- Read `VISION.md` for the full phase plan and architecture principles
- Explore the domain skills documentation under `docs/docs/domain-skills/`
- Check the architecture diagrams under `diagrams/mermaid/`
- Set up CI/CD with `.github/workflows/release.yml`

## Troubleshooting

### Yamllint errors
```bash
# Check specific file
yamllint config/hermes/config.yaml
# Fix indentation (must be 2-space)
```

### Model not found
```bash
# Pull missing model
ollama pull <model-name>
# Verify with
ollama list | grep <model-name>
```

### Personality not resolving
Ensure the `personality` field in a skill YAML matches the `id` field in a personality YAML exactly (case-sensitive).

---

You're now ready to operate Hermes AI OS. For questions, see the full documentation or the architecture overview.
