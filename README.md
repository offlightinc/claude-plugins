# Team Offlight Plugins for Claude Code

Claude Code plugins maintained by Team Offlight.

## Plugins

| Plugin | Commands | Description |
|--------|----------|-------------|
| `dual` | `/dual:search`, `/dual:plan`, `--agent dual:code` | Multi-model collaboration — Claude + Codex for fact verification, plan review, and code review |
| `manage-skill` | `/manage-skill` | Manage Claude Code extensions (skills, hooks, agents) — create, modify, rename, delete with deployment pipeline |
| `my-knowledge-base` | `/my-knowledge-base:explain`, `/my-knowledge-base:update` | Compound your knowledge across sessions — tracks what you know, what you're learning, with verified assessments |
| `session-commit` | `/session-commit` | Commit only files changed in the current session — no git diff/status needed |
| `spawn` | `/spawn` | Spawn a new Claude Code session in a Warp terminal tab |
| `tasklist` | `/tasklist:create`, `/tasklist:list`, `/tasklist:load` | Browse and load saved Claude Code Task Lists |
| `ulp` | `/ulp` | Ultimate Loop Planning — 6-stage critique-based planning loop |

## Installation

Add marketplace to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "team-offlight": {
      "source": {
        "source": "github",
        "repo": "namho-hong/team-offlight-claude-code-plugins"
      }
    }
  }
}
```

Then install individual plugins:

```bash
claude plugin install dual@team-offlight --scope project
claude plugin install manage-skill@team-offlight --scope project
claude plugin install my-knowledge-base@team-offlight --scope project
claude plugin install session-commit@team-offlight --scope project
claude plugin install spawn@team-offlight --scope project
claude plugin install tasklist@team-offlight --scope project
claude plugin install ulp@team-offlight --scope project
```

## License

MIT
