# Automated issue → fix → test → review pipeline

This repo runs a 4-stage automation, powered by your **Claude Code subscription**
(Pro/Max) instead of a pay-as-you-go API key.

| Stage | Where | What it does |
|-------|-------|--------------|
| 1. Fetch issue | `nightly-autofix.yml` (cron) | Picks the oldest open issue labelled `auto-fix`. |
| 2. Fix + PR | `nightly-autofix.yml` | Claude implements a minimal fix on `fix/issue-N` and opens a PR. |
| 3. Test branch | `pr-checks.yml` (`test` job) | `flutter analyze` + `flutter test` on the PR. |
| 4. Review + notify | `pr-checks.yml` (`review` + `notify` jobs) | **Llama + Mistral + Gemini + Groq** each post an independent review comment. Claude does NOT review — it only writes code. |

## Schedule

The nightly job runs at **02:00 IST every day** (`cron: "30 20 * * *"`, which is
20:30 UTC — GitHub cron is always UTC). Change the cron line if you move timezones.
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
| `CLAUDE_CODE_OAUTH_TOKEN` | **Yes** | Subscription auth for the fix step (Coder A). |
| `GEMINI_API_KEY` | Recommended | Free-tier key from [Google AI Studio](https://aistudio.google.com/apikey). Coder B in ensemble + 3rd reviewer in PR checks. |
| `GROQ_API_KEY` | Optional | Free-tier key from [groq.com](https://console.groq.com). Adds a 2nd judge vote in ensemble + 4th reviewer in PR checks. Fast inference, free signup. |
| `GH_PAT` | Recommended | A fine-grained PAT (Contents + Pull requests: write). Used so the auto-opened PR **triggers** `pr-checks.yml`. See note below. |
| `TELEGRAM_BOT_TOKEN` | Optional | Bot token from [@BotFather](https://t.me/BotFather) for notifications. |
| `TELEGRAM_CHAT_ID` | Optional | Your chat ID (message the bot, then read it from `https://api.telegram.org/bot<token>/getUpdates`). |

If `GEMINI_API_KEY` and `GROQ_API_KEY` are absent, the Llama + Mistral reviews via
GitHub Models still run automatically — they use the built-in `GITHUB_TOKEN` and need
no extra account.

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

## Multi-AI PR review

Every PR now gets reviewed by **all available free AI services** — never by Claude (Claude
writes the code; different models catch bugs in it).

| Reviewer | Always active? | Key needed |
|----------|---------------|------------|
| 🦙 Llama 3.3 70B (GitHub Models) | ✅ Yes | None — uses `GITHUB_TOKEN` |
| 🌬️ Mistral Large (GitHub Models)  | ✅ Yes | None — uses `GITHUB_TOKEN` |
| ✨ Gemini 1.5 Flash               | If key set | `GEMINI_API_KEY` (free) |
| ⚡ Llama 3.3 70B (Groq)           | If key set | `GROQ_API_KEY` (free) |

Each posts its own PR comment. You get 2–4 independent perspectives before merging.
Logic lives in [`.github/scripts/multi_ai_review.py`](scripts/multi_ai_review.py).

## Ensemble mode (multi-AI + judge + test-verified loop)

`nightly-ensemble.yml` is an upgraded alternative to `nightly-autofix.yml`. Instead of
one model, it runs:

1. **Coder A — Claude Code** (your subscription) fixes the issue independently.
2. **Coder B — Gemini CLI** (free tier) fixes the same issue independently.
3. **Judge — Llama-3.3-70B** via GitHub Models (FREE, built-in `GITHUB_TOKEN`, no extra
   key) picks the better of the two candidates. If `GROQ_API_KEY` is set, a second Groq
   judge votes too and the winner is decided by majority.
4. **Oracle — your test suite** (`flutter analyze` + `flutter test`) decides pass/fail.
5. If it fails, the failure log is fed back and the loop repeats (default **3** iterations).
6. On pass → opens a normal PR. After the budget is exhausted → opens a **draft** PR with
   the logs for you to take over.

The judge never decides correctness — the **tests do**. That's what keeps it honest.

To use it: add `GEMINI_API_KEY`, then **disable `nightly-autofix.yml`** (Actions tab →
the workflow → ⋯ → Disable) so the two don't fight over the same issue. Logic lives in
[`.github/scripts/ensemble_fix.py`](scripts/ensemble_fix.py); tune `MAX_ITERS` or swap
models there.

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
