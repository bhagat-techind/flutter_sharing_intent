# Automated issue → fix → test → review pipeline

This repo runs a 4-stage automation, powered by your **Claude Code subscription**
(Pro/Max) instead of a pay-as-you-go API key.

| Stage | Where | What it does |
|-------|-------|--------------|
| 1. Fetch issue | `nightly-autofix.yml` (cron) | Picks the oldest open issue labelled `auto-fix`. |
| 2. Fix + PR | `nightly-autofix.yml` | Claude implements a minimal fix on `fix/issue-N` and opens a PR. |
| 3. Test branch | `pr-checks.yml` (`test` job) | `flutter analyze` + `flutter test` on the PR. |
| 4. Review + notify | `pr-checks.yml` (`review` + `notify` jobs) | Claude reviews the diff, then Telegram pings you with pass/fail. |

## Schedule

The nightly job runs at **01:30 IST every day** (`cron: "0 20 * * *"`, which is 20:00
UTC — GitHub cron is always UTC). Change the cron line if you move timezones.
You can also run it on demand from **Actions → Nightly Auto-Fix → Run workflow**, with
an optional issue number.

> Note: GitHub may delay scheduled runs by a few minutes under load, scheduled
> workflows only run from the **default branch**, and they auto-disable after ~60 days
> of zero repo activity. None of this affects manual runs.

## One-time setup

### 1. Generate a subscription token (no API key needed)

On your machine, signed in to Claude Code with your Pro/Max account:

```bash
claude setup-token
```

Copy the token it prints.

### 2. Add repository secrets

GitHub → repo **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Required? | Purpose |
|--------|-----------|---------|
| `CLAUDE_CODE_OAUTH_TOKEN` | **Yes** | Subscription auth for the fix + review steps. |
| `GEMINI_API_KEY` | For ensemble mode | Free-tier key from [Google AI Studio](https://aistudio.google.com/apikey). Second solver. |
| `GH_PAT` | Recommended | A fine-grained PAT (Contents + Pull requests: write). Used so the auto-opened PR **triggers** `pr-checks.yml`. See note below. |
| `TELEGRAM_BOT_TOKEN` | Optional | Bot token from [@BotFather](https://t.me/BotFather) for notifications. |
| `TELEGRAM_CHAT_ID` | Optional | Your chat ID (message the bot, then read it from `https://api.telegram.org/bot<token>/getUpdates`). |

If the Telegram secrets are absent, the `notify` job simply skips — everything else
still works (GitHub already emails you on PR/CI events).

### 3. Create the `auto-fix` label

```bash
gh label create auto-fix --description "Let the nightly agent attempt this" --color 0E8A16
```

Then label any issue you want auto-fixed. Leave unlabelled issues alone.

### 4. Enable PR creation by Actions

Settings → **Actions → General → Workflow permissions** → tick
**"Allow GitHub Actions to create and approve pull requests."**

## Why the `GH_PAT`?

PRs created with the built-in `GITHUB_TOKEN` **do not** trigger other workflows (GitHub
prevents that recursion). So if you skip `GH_PAT`, the nightly job will open the PR, but
`pr-checks.yml` won't fire automatically — you'd start it via **Run workflow**. With a
`GH_PAT`, the PR triggers tests + review normally.

## Ensemble mode (multi-AI + judge + test-verified loop)

`nightly-ensemble.yml` is an upgraded alternative to `nightly-autofix.yml`. Instead of
one model, it runs:

1. **Solver A — Claude Code** (your subscription) fixes the issue independently.
2. **Solver B — Gemini CLI** (free tier) fixes the same issue independently.
3. **Judge — Claude** merges the strongest parts of both into one optimized candidate.
4. **Oracle — your test suite** (`flutter analyze` + `flutter test`) decides pass/fail.
5. If it fails, the failure log is fed back and the loop repeats (default **3** iterations).
6. On pass → opens a normal PR. After the budget is exhausted → opens a **draft** PR with
   the logs for you to take over.

The judge never decides correctness — the **tests do**. That's what keeps it honest.

To use it: add `GEMINI_API_KEY`, then **disable `nightly-autofix.yml`** (Actions tab →
the workflow → ⋯ → Disable) so the two don't fight over the same issue. Logic lives in
[`.github/scripts/ensemble_fix.py`](scripts/ensemble_fix.py); tune `MAX_ITERS` or swap
models there.

Other genuinely-free models you can drop in as Solver B or the judge: **GitHub Models**
(`Authorization: Bearer $GITHUB_TOKEN`, no extra account), **Groq**, or **Cerebras** free
tiers. Gemini CLI is the default because it's *agentic* (edits files directly), like
Claude Code.

## Safety notes

- **Never auto-merge.** PRs are for your review. Keep branch protection on `main`.
- The fix step is reliable only on **small, well-scoped issues**. Large/ambiguous ones
  will (by design) get a comment instead of a PR.
- Issue text is treated as untrusted (prompt-injection guard in the prompt), but you
  should still glance at every generated PR.
- Subscription accounts have **usage limits** intended for interactive use; nightly
  automation consumes from the same quota. The workflows default to **Sonnet** to be
  gentle — bump `--model claude-opus-4-8` in the YAML for harder issues if your tier
  allows it.
