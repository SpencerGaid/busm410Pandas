---
name: project-audit
description: Record Spencer's human checks of agent work in the five-category audit log and maintain the approved audit protocol.
---

# Project Audit Skill

Use this skill when Spencer checks, corrects, challenges, verifies, or redirects the agent's project work.

## Read first

Read:

1. `AGENTS.md`
2. `Other/audit_protocol.md`
3. `Other/audit_log.md`

## What counts

An audit entry must describe an action Spencer actually took to check the agent. Examples include comparing a number with BigQuery, checking documentation, challenging an assumption, changing the analysis, or correcting the agent's working instructions.

The following do not count by themselves:

- the agent checking its own arithmetic;
- an automated query, test, or lint result;
- the agent saying that a source is reliable;
- a correction the agent discovered without Spencer's review.

## Categories

Choose exactly one:

1. Caught an error
2. Verified a claim
3. Separated fact from opinion
4. Changed the analysis
5. Improved the agent's instructions

## Approval workflow

1. Draft the proposed entry in plain language.
2. Show Spencer the category, wording, and result.
3. Ask Spencer to approve or revise it.
4. Do not add it to an official category table or count until Spencer explicitly approves it.
5. After approval, append it with the next stable entry number and update the summary table.

Use the same approval process for material additions to `Other/audit_protocol.md`. A draft may be committed for review if its status is clearly labeled.

## Entry format

| # | Date | What the AI said or did | How Spencer checked it | Result |
|---|---|---|---|---|

State the practical result: confirmed, corrected, reframed, removed, or added. Include a source or query name when it helps another reader reproduce the check.

