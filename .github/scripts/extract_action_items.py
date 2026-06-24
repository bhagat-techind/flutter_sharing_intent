#!/usr/bin/env python3
"""
Read PR comment bodies from stdin (joined by ---COMMENT--- separators) and
extract deduplicated bullet items from every "**Action Items:**" section.

Usage (resolver-rerun.yml):
  gh pr view "$PR_NUM" --json comments \
    --jq '[.comments[].body] | join("\n---COMMENT---\n")' \
  | python3 .github/scripts/extract_action_items.py \
  | tee /tmp/review_feedback.txt
"""
import re
import sys

text = sys.stdin.read()
sections = re.findall(r'\*\*Action Items:\*\*\n((?:- .+\n?)+)', text)

items = []
for s in sections:
    for item in re.findall(r'- (.+)', s):
        if not re.match(r'none', item.strip(), re.I):
            items.append(item.strip())

seen: set = set()
unique: list = []
for x in items:
    if x not in seen:
        seen.add(x)
        unique.append(x)

if unique:
    print("AI reviewers raised these concerns — ALL must be addressed:")
    for item in unique:
        print(f"  - {item}")
else:
    print("No specific action items found in reviews.")
