# Audit Protocol

> **Approval status:** Drafted for Spencer's review on 2026-11-03. It becomes the team's active protocol after Spencer approves it.

## Purpose

This protocol records how Spencer directs and checks the AI agent. The audit log is evidence of **human review**. The agent's own calculations, automated checks, or statements that it reviewed its work do not count as human audit entries.

## Before the agent changes analysis

1. Read `AGENTS.md`, this protocol, the audit log, and the project-audit skill.
2. Preserve the dataset, date range, unit of analysis, and confirmed definitions unless Spencer changes them.
3. Show the source or query behind a new factual claim.
4. Use a branch and pull request for material repository changes.

## Checks Spencer can perform

Spencer can audit the agent by doing one or more of the following:

- compare a stated number with the BigQuery result grid;
- compare a field definition or price with the linked source document;
- ask whether wording is a documented fact, an assumption, or an inference;
- challenge the unit of analysis, benchmark, filter, or value formula;
- point out when the agent's workflow or repository instructions should change.

## How an audit entry is added

1. The agent drafts one concise entry using Spencer's actual check and its result.
2. The agent assigns the entry to one of the five category tables.
3. Spencer reviews the wording and explicitly approves it or asks for a revision.
4. Only after approval does the agent add it to an official category table and update the summary count.
5. Entry numbers remain stable if an entry is revised or moved.

## Required evidence in each entry

Each entry includes the date, what the agent said or did, how Spencer checked it, and what changed or was confirmed. Links or query names are included when they make the check reproducible.

## Guardrails

- Never invent a human check.
- Never count the agent's own validation as Spencer's audit.
- Never turn a proposed or pending entry into an approved entry without Spencer's approval.
- Keep interpretation separate from measured facts.
- Record corrections in the relevant project file as well as in the audit log.

