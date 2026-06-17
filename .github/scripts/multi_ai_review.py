#!/usr/bin/env python3
"""
Multi-AI PR reviewer — posts independent reviews from several free AI services.

Services (all free, no paid API key required for the first two):
  1. Llama-3.3-70B   via GitHub Models  — built-in GITHUB_TOKEN, always available
  2. Mistral-Large   via GitHub Models  — built-in GITHUB_TOKEN, always available
  3. Gemini 1.5 Flash via Google AI     — free tier, needs GEMINI_API_KEY (optional)
  4. Llama-3.3-70B   via Groq           — free tier, needs GROQ_API_KEY    (optional)

Each reviewer posts its own PR comment so you get independent opinions side-by-side.
Claude is intentionally excluded from PR review — it handles code generation only.

Required env: GITHUB_TOKEN (injected automatically), PR_NUMBER, GITHUB_REPOSITORY
Optional env: GEMINI_API_KEY, GROQ_API_KEY
"""
import json
import os
import subprocess
import sys
import textwrap
import urllib.request

PR_NUMBER = os.environ.get("PR_NUMBER", "")
REPO = os.environ.get("GITHUB_REPOSITORY", "")
GH_TOKEN = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN", "")

MODELS_ENDPOINT = "https://models.github.ai/inference/chat/completions"
GROQ_ENDPOINT = "https://api.groq.com/openai/v1/chat/completions"

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

    Skip style, formatting, and nitpicks. Be concise — use short bullet points.
    Start your response with a single-line verdict:
      ✅ LGTM  |  ⚠️ Minor issues  |  ❌ Needs changes

    Then list findings (if any) grouped by severity.
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


def _call_openai_compat(endpoint, model, token, label, diff):
    """Call any OpenAI-compatible endpoint (GitHub Models, Groq, etc.)."""
    prompt = REVIEW_PROMPT.format(diff=diff)
    body = json.dumps({
        "model": model,
        "temperature": 0.3,
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": prompt}],
    }).encode()
    req = urllib.request.Request(
        endpoint, data=body,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            data = json.loads(r.read().decode())
        return data["choices"][0]["message"]["content"]
    except Exception as e:
        print(f"[{label}] error: {e}", flush=True)
        return None


def _call_gemini(api_key, diff):
    prompt = REVIEW_PROMPT.format(diff=diff)
    url = (
        "https://generativelanguage.googleapis.com/v1beta/models/"
        f"gemini-1.5-flash:generateContent?key={api_key}"
    )
    body = json.dumps({
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"temperature": 0.3, "maxOutputTokens": 1024},
    }).encode()
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            data = json.loads(r.read().decode())
        return data["candidates"][0]["content"]["parts"][0]["text"]
    except Exception as e:
        print(f"[Gemini] error: {e}", flush=True)
        return None


def main():
    if not PR_NUMBER:
        sys.exit("PR_NUMBER env var is required.")

    diff = get_pr_diff()
    if not diff.strip():
        print("No diff found — skipping multi-AI review.")
        return

    reviews = []

    # 1. Llama-3.3-70B via GitHub Models (always free, no new secret)
    review = _call_openai_compat(
        MODELS_ENDPOINT,
        "meta-llama/Llama-3.3-70B-Instruct",
        GH_TOKEN,
        "Llama-3.3 (GitHub Models)",
        diff,
    )
    if review:
        reviews.append(("🦙 **Llama 3.3 70B** (GitHub Models, free)", review))
        print("[Llama-GitHub-Models] review complete", flush=True)

    # 2. Mistral Large via GitHub Models (always free, no new secret)
    review = _call_openai_compat(
        MODELS_ENDPOINT,
        "mistral-ai/Mistral-Large-2411",
        GH_TOKEN,
        "Mistral-Large (GitHub Models)",
        diff,
    )
    if review:
        reviews.append(("🌬️ **Mistral Large** (GitHub Models, free)", review))
        print("[Mistral-GitHub-Models] review complete", flush=True)

    # 3. Gemini 1.5 Flash (free tier — optional GEMINI_API_KEY)
    gemini_key = os.environ.get("GEMINI_API_KEY", "")
    if gemini_key:
        review = _call_gemini(gemini_key, diff)
        if review:
            reviews.append(("✨ **Gemini 1.5 Flash** (Google AI, free tier)", review))
            print("[Gemini] review complete", flush=True)
    else:
        print("[Gemini] GEMINI_API_KEY not set — skipping.", flush=True)

    # 4. Llama-3.3-70B via Groq (free tier — optional GROQ_API_KEY)
    groq_key = os.environ.get("GROQ_API_KEY", "")
    if groq_key:
        review = _call_openai_compat(
            GROQ_ENDPOINT,
            "llama-3.3-70b-versatile",
            groq_key,
            "Llama-3.3 (Groq)",
            diff,
        )
        if review:
            reviews.append(("⚡ **Llama 3.3 70B** (Groq, free tier)", review))
            print("[Groq] review complete", flush=True)
    else:
        print("[Groq] GROQ_API_KEY not set — skipping.", flush=True)

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
        print(f"Posted review: {name}", flush=True)

    print(f"\nPosted {len(reviews)} review comment(s).")


if __name__ == "__main__":
    main()
