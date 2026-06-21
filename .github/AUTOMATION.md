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
| `GEMINI_API_KEY` | Recommended | Free-tier key from [Google AI Studio](https://aistudio.google.com/apikey). Coder B in ensemble + reviewer in PR checks. |
| `COPILOT_PAT` | Optional | Classic PAT from your **Copilot-enabled GitHub account** (can be a different account than the repo owner — see note below). Adds Copilot as a judge + PR reviewer. |
| `GROQ_API_KEY` | Optional | Free-tier key from [groq.com](https://console.groq.com). Adds Llama judge vote + PR reviewer. |
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

## `COPILOT_PAT` — using Copilot from a different account

Your Copilot subscription can be on Account B while the repo lives on Account A.
To use it:

1. Sign into **Account B** (your Copilot account) on github.com.
2. Go to **Settings → Developer settings → Personal access tokens → Tokens (classic)**.
3. Generate a new token — no special scopes needed beyond the defaults (or just `user:read`).
4. Copy the token and add it as `COPILOT_PAT` in Account A's repo secrets.

The workflow exchanges that token for a short-lived Copilot session token automatically.
If the token is wrong or the subscription is inactive, Copilot is silently skipped.

## Nightly Auto-Fix vs Nightly Ensemble Fix — what's the difference?

| | **Nightly Auto-Fix** | **Nightly Ensemble Fix** |
|-|---------------------|------------------------|
| Coders | Claude only | Claude **+** Gemini **+** Copilot (all three, independently) |
| Judge role | None — Claude decides | Synthesise best parts from ALL 3 solutions (not just pick one) |
| Judges | — | Llama + ChatGPT + DeepSeek + Copilot + Groq (majority picks base; all synthesis hints merged) |
| Stage 1 oracle | `flutter analyze` (inside Claude) | `flutter analyze` + `flutter test` (objective, after synthesis applied) |
| Stage 2 oracle | — | Production gate: no warnings, no debug prints, no TODO/FIXME in diff |
| PR opened when | Stage 1 passes | Stage 1 **and** Stage 2 both pass → normal PR; Stage 1 only → draft PR |
| Retry loop | No — one attempt | Yes — up to 3 iterations with failure feedback |
| Speed | ~5 min | ~30–45 min |
| Best for | Simple, well-defined bugs | Harder or ambiguous issues |
| Secrets needed | `CLAUDE_CODE_OAUTH_TOKEN` | + `GEMINI_API_KEY`, `COPILOT_PAT` |

**Use only one at a time.** Both pick from the same issue queue, so running both means they race to fix the same issue. Disable Auto-Fix (Actions → workflow → ⋯ → Disable) when you switch to Ensemble.

**Recommendation:** start with Auto-Fix. When it consistently fails on your issues, switch to Ensemble.

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
| 🤖 ChatGPT / GPT-4o (GitHub Models) | ✅ Yes | None — uses `GITHUB_TOKEN` |
| 🦙 Llama 3.3 70B (GitHub Models)    | ✅ Yes | None — uses `GITHUB_TOKEN` |
| 🐋 DeepSeek V3 (GitHub Models)      | ✅ Yes | None — uses `GITHUB_TOKEN` |
| 🌬️ Mistral Medium 3 (GitHub Models) | ✅ Yes | None — uses `GITHUB_TOKEN` |
| 🤖 GitHub Copilot                   | If key set | `COPILOT_PAT` (your Copilot account) |
| ✨ Gemini 2.0 Flash                 | If key set | `GEMINI_API_KEY` (free) |
| ⚡ Llama 3.3 70B (Groq)             | If key set | `GROQ_API_KEY` (free) |

Each posts its own PR comment. You get 2–4 independent perspectives before merging.
Logic lives in [`.github/scripts/multi_ai_review.py`](scripts/multi_ai_review.py).

## Ensemble mode (3-coder synthesis + 2-stage quality gate)

`nightly-ensemble.yml` runs a full ensemble pipeline instead of a single model:

1. **Coder A — Claude Code** (your subscription) fixes the issue independently.
2. **Coder B — Gemini CLI** (free tier) fixes the same issue independently.
3. **Coder C — GitHub Copilot** (via `COPILOT_PAT`) generates a unified diff via Chat API.
4. **Judge panel — Llama + ChatGPT + DeepSeek + Copilot + Groq** reviews ALL 3 candidates.
   They do NOT just pick one — they synthesise: each judge identifies the best base candidate
   and suggests specific improvements to take from the other two. Majority decides the base;
   all synthesis hints are merged and Claude applies them on top.
5. **Stage 1 oracle — `flutter analyze` + `flutter test`** — objective pass/fail. If it
   fails, the failure log is fed back and the loop repeats (default **3** iterations).
6. **Stage 2 oracle — production gate** — runs only when Stage 1 passes. Checks: no
   warnings, no `print()`/`debugPrint()` debug statements, no `TODO`/`FIXME` in the diff.
7. Both stages pass → normal PR. Stage 1 only → draft PR with production concerns listed.
   Budget exhausted → draft PR for human review.

The judges never decide correctness — the **test suite and production gate do**.

To use it: add `GEMINI_API_KEY` + `COPILOT_PAT`, then **disable `nightly-autofix.yml`**
(Actions tab → the workflow → ⋯ → Disable) so the two don't fight over the same issue.
Logic lives in [`.github/scripts/ensemble_fix.py`](scripts/ensemble_fix.py); tune
`MAX_ITERS` there.

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
