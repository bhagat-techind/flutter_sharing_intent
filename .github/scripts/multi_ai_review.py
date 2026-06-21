#!/usr/bin/env python3
"""
Multi-AI PR reviewer — posts independent reviews from several free AI services.

GitHub Models (all free, built-in GITHUB_TOKEN, no extra key needed):
  1. ChatGPT / GPT-4o          openai/gpt-4o
  2. Llama 3.3 70B             meta/llama-3.3-70b-instruct
  3. DeepSeek V3               deepseek/deepseek-v3-0324   ← great at code
  4. Mistral Medium 3          mistral-ai/mistral-medium-2505

Optional (need extra API key, both free-tier):
  5. Gemini 2.0 Flash          GEMINI_API_KEY
  6. Llama 3.3 70B via Groq    GROQ_API_KEY

Each reviewer posts its own PR comment — independent perspectives side by side.
Claude is excluded from PR review (it writes code; others review it).

Model IDs verified live against models.github.ai on 2026-06-18.
Re-verify with: python3 .github/scripts/verify_models.py

Required env (auto-set in Actions): GITHUB_TOKEN, PR_NUMBER, GITHUB_REPOSITORY
Optional env: GEMINI_API_KEY, GROQ_API_KEY

Local testing:
  export PR_NUMBER=<number>
  export GITHUB_REPOSITORY=owner/repo
  python3 .github/scripts/multi_ai_review.py
"""
import json
import os
import subprocess
import sys
import textwrap
import urllib.error
import urllib.request
import urllib.parse

PR_NUMBER = os.environ.get("PR_NUMBER", "")
REPO = os.environ.get("GITHUB_REPOSITORY", "")

# GitHub token: env var first, then auto-detect from gh CLI (local testing)
GH_TOKEN = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN", "")
if not GH_TOKEN:
    try:
        r = subprocess.run(["gh", "auth", "token"], capture_output=True, text=True)
        if r.returncode == 0:
            GH_TOKEN = r.stdout.strip()
            print("[info] Using token from `gh auth token`", flush=True)
    except Exception:
        pass

# Single verified endpoint — model IDs below are confirmed for this URL only.
# The Azure endpoint (models.inference.ai.azure.com) uses a DIFFERENT ID format.
GITHUB_MODELS_URL = "https://models.github.ai/inference/chat/completions"
GROQ_ENDPOINT = "https://api.groq.com/openai/v1/chat/completions"

# Verified working model IDs on GITHUB_MODELS_URL (tested 2026-06-18)
MODELS = {
    "chatgpt":  "openai/gpt-4o",
    "llama":    "meta/llama-3.3-70b-instruct",
    "deepseek": "deepseek/deepseek-v3-0324",
    "mistral":  "mistral-ai/mistral-medium-2505",
}

REVIEW_PROMPT = textwrap.dedent("""\
    You are a senior mobile developer reviewing a Flutter plugin pull request.
    The plugin has iOS (Swift) and Android (Kotlin) native code.

    PR diff (unified format):
    {diff}

    Review ONLY for real issues:
    1. Logic bugs — wrong conditions, off-by-ones, unhandled nil/null
    2. Platform issues — iOS ARC retain cycles, Android lifecycle leaks, missing permissions
    3. Public API breaks — changed signatures, removed exported symbols
    4. Security — data leaks, improper file/permission access
    5. Obvious performance regressions

    Skip style, formatting, and nitpicks. Be concise — short bullet points.

    You MUST follow this exact output structure:

    Start with a one-line verdict: ✅ LGTM | ⚠️ Minor issues | ❌ Needs changes

    Then a short paragraph (2-3 sentences) summarising what the PR does.

    Then findings grouped by severity (omit sections that have no findings):
    **Critical:** (blocks merge)
    **Minor:** (should fix before merge)

    End with this section — always include it, even if the list is empty:
    **Action Items:**
    - <concrete thing the author should do, e.g. "Add null check for X in file Y">
    - <...>
    (If there are no action items, write: - None — ready to merge.)
""")


def get_pr_diff():
    result = subprocess.run(
        ["gh", "pr", "diff", PR_NUMBER],
        capture_output=True, text=True,
        env={**os.environ, "GH_TOKEN": GH_TOKEN},
    )
    if result.returncode != 0:
        print(f"Could not fetch PR diff: {result.stderr}", flush=True)
        return ""
    return result.stdout[:14000]


def post_comment(body):
    result = subprocess.run(
        ["gh", "pr", "comment", PR_NUMBER, "--body", body],
        capture_output=True, text=True,
        env={**os.environ, "GH_TOKEN": GH_TOKEN},
    )
    if result.returncode != 0:
        print(f"Failed to post comment: {result.stderr}", flush=True)


def _call_openai_compat(url, model_id, token, label, diff):
    """Call any OpenAI-compatible endpoint. Returns review text or None."""
    body = json.dumps({
        "model": model_id,
        "temperature": 0.3,
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": REVIEW_PROMPT.format(diff=diff)}],
    }).encode()
    req = urllib.request.Request(url, data=body, headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    })
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return json.loads(r.read().decode())["choices"][0]["message"]["content"]
    except urllib.error.HTTPError as e:
        err = e.read().decode()[:300]
        print(f"[{label}] HTTP {e.code}: {err}", flush=True)
        return None
    except Exception as e:
        print(f"[{label}] error: {e}", flush=True)
        return None


def _call_copilot(copilot_pat, label, diff):
    """
    GitHub Copilot Chat completions.
    Requires a PAT from a GitHub account with an active Copilot subscription
    (can be a different account from the repo owner — add as COPILOT_PAT secret).

    Uses the same internal API that VSCode Copilot Chat uses. Skips gracefully
    if the token is wrong or the Copilot subscription is inactive.
    """
    # Step 1: exchange the PAT for a short-lived Copilot session token
    try:
        token_req = urllib.request.Request(
            "https://api.github.com/copilot_internal/v2/token",
            headers={
                "Authorization": f"Bearer {copilot_pat}",
                "Accept": "application/json",
                "Editor-Version": "vscode/1.96.0",
                "Editor-Plugin-Version": "copilot-chat/0.22.4",
                "User-Agent": "GitHubCopilotChat/0.22.4",
            },
        )
        with urllib.request.urlopen(token_req, timeout=15) as r:
            session_token = json.loads(r.read().decode())["token"]
    except urllib.error.HTTPError as e:
        print(f"[{label}] Could not get Copilot token — HTTP {e.code}: {e.read().decode()[:200]}", flush=True)
        return None
    except Exception as e:
        print(f"[{label}] Could not get Copilot token: {e}", flush=True)
        return None

    # Step 2: call Copilot Chat completions with the session token
    body = json.dumps({
        "model": "gpt-4o",
        "temperature": 0.3,
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": REVIEW_PROMPT.format(diff=diff)}],
    }).encode()
    req = urllib.request.Request(
        "https://api.githubcopilot.com/chat/completions",
        data=body,
        headers={
            "Authorization": f"Bearer {session_token}",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Editor-Version": "vscode/1.96.0",
            "Editor-Plugin-Version": "copilot-chat/0.22.4",
            "User-Agent": "GitHubCopilotChat/0.22.4",
            "Copilot-Integration-Id": "vscode-chat",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return json.loads(r.read().decode())["choices"][0]["message"]["content"]
    except urllib.error.HTTPError as e:
        print(f"[{label}] HTTP {e.code}: {e.read().decode()[:300]}", flush=True)
        return None
    except Exception as e:
        print(f"[{label}] error: {e}", flush=True)
        return None


def _call_gemini(api_key, diff):
    """Gemini REST API — tries 2.0-flash then 1.5-flash."""
    prompt = REVIEW_PROMPT.format(diff=diff)
    for model in ("gemini-2.0-flash", "gemini-1.5-flash"):
        url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            f"{model}:generateContent?key={api_key}"
        )
        body = json.dumps({
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.3, "maxOutputTokens": 1024},
        }).encode()
        req = urllib.request.Request(url, data=body, headers={
            "Content-Type": "application/json",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        })
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                data = json.loads(r.read().decode())
            print(f"[Gemini] succeeded with {model}", flush=True)
            return data["candidates"][0]["content"]["parts"][0]["text"]
        except urllib.error.HTTPError as e:
            print(f"[Gemini/{model}] HTTP {e.code}: {e.read().decode()[:200]}", flush=True)
        except Exception as e:
            print(f"[Gemini/{model}] error: {e}", flush=True)
    return None


def main():
    if not PR_NUMBER:
        sys.exit("PR_NUMBER env var is required.")

    diff = get_pr_diff()
    if not diff.strip():
        print("No diff found — skipping multi-AI review.")
        return

    reviews = []

    # ── GitHub Models reviewers (free, no extra secret) ──────────────────────
    github_reviewers = [
        ("🤖 **ChatGPT / GPT-4o** (GitHub Models)",      MODELS["chatgpt"]),
        ("🦙 **Llama 3.3 70B** (GitHub Models)",          MODELS["llama"]),
        ("🐋 **DeepSeek V3** (GitHub Models)",            MODELS["deepseek"]),
        ("🌬️ **Mistral Medium 3** (GitHub Models)",       MODELS["mistral"]),
    ]
    for name, model_id in github_reviewers:
        review = _call_openai_compat(GITHUB_MODELS_URL, model_id, GH_TOKEN, name, diff)
        if review:
            reviews.append((name, review))
            print(f"[OK] {name}", flush=True)

    # ── GitHub Copilot (optional — add COPILOT_PAT from your Copilot account) ─
    # Your Copilot subscription can be on a DIFFERENT GitHub account than the
    # repo owner. Create a classic PAT on that account and add it as COPILOT_PAT.
    copilot_pat = os.environ.get("COPILOT_PAT", "")
    if copilot_pat:
        review = _call_copilot(copilot_pat, "GitHub Copilot", diff)
        if review:
            reviews.append(("🤖 **GitHub Copilot** (your Copilot account)", review))
            print("[OK] GitHub Copilot", flush=True)
    else:
        print("[skip] COPILOT_PAT not set", flush=True)

    # ── Gemini (optional — add GEMINI_API_KEY secret) ────────────────────────
    gemini_key = os.environ.get("GEMINI_API_KEY", "")
    if gemini_key:
        review = _call_gemini(gemini_key, diff)
        if review:
            reviews.append(("✨ **Gemini 2.0 Flash** (Google AI)", review))
            print("[OK] Gemini", flush=True)
    else:
        print("[skip] GEMINI_API_KEY not set", flush=True)

    # ── Groq (optional — add GROQ_API_KEY secret) ────────────────────────────
    groq_key = os.environ.get("GROQ_API_KEY", "")
    if groq_key:
        review = _call_openai_compat(
            GROQ_ENDPOINT, "llama-3.3-70b-versatile", groq_key, "Groq/Llama", diff)
        if review:
            reviews.append(("⚡ **Llama 3.3 70B** (Groq)", review))
            print("[OK] Groq", flush=True)
    else:
        print("[skip] GROQ_API_KEY not set", flush=True)

    if not reviews:
        print("All AI reviewers failed — no comments posted.")
        return

    for name, content in reviews:
        comment = (
            f"### {name} — Automated Code Review\n\n"
            f"{content}\n\n"
            f"---\n"
            f"*Auto-generated · not a substitute for human review · verify before merging*"
        )
        post_comment(comment)
        print(f"Posted: {name}", flush=True)

    print(f"\nDone — {len(reviews)} review(s) posted.")


if __name__ == "__main__":
    main()
