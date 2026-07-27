---
name: Kanban Issue
about: Standard issue template for GitHub RAG project board
title: ""
labels: []
assignees: []
---

## Metadata

<!-- Machine-readable metadata for RAG indexing. Fill in all applicable fields. -->

| Field        | Value                        |
| ------------ | ---------------------------- |
| **Type**     | `feature | bug | docs | refactor | infra` |
| **Priority** | `critical | high | medium | low` |
| **Area**     | _e.g. ingestion, embeddings, API, UI, auth, infra_ |
| **Status**   | `backlog | todo | in-progress | review | done` |

---

## Summary

<!-- One-paragraph description. This is the primary text RAG will match on. Be specific: include WHAT and WHY. -->

## Context & Background

<!-- Why does this issue exist? What problem does it solve? Link to discussions, incidents, or prior issues. This section provides semantic context for retrieval. -->

- **Motivation:**
- **Related discussion / RFC:**
- **Supersedes / related to:** <!-- e.g. "Follows #42", "Split from #18" -->

---

## Acceptance Criteria

<!-- Define clear, testable outcomes. Each criterion should be independently verifiable. These become evaluation targets when RAG answers "is this feature done?" -->

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

---

## Technical Details

<!-- Implementation notes, architecture decisions, constraints, data models, API contracts. This section enriches RAG answers to "how does X work?" -->

### Approach

### Data model / schema changes

### API / interface changes

### Constraints & trade-offs

---

## Dependencies

<!-- Explicitly list blocking or related work. Enables graph-based retrieval and Kanban dependency tracking. -->

- **Blocked by:** <!-- issue numbers -->
- **Blocks:** <!-- issue numbers -->
- **External dependencies:** <!-- services, libraries, APIs -->

---

## Testing & Validation

<!-- How will this be tested? What signals confirm correct behavior? Helps RAG answer "how is X tested?" -->

- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual verification steps

**Verification steps:**

1. Step 1
2. Step 2

---
## References

<!-- External links, docs, papers, prior art. These enrich RAG context with authoritative sources. -->

- [Link title](url)

---

## Notes

<!-- Free-form space for ongoing updates, decisions, and discoveries. Date-stamp entries for temporal context in RAG. -->

<!-- Example:
- **2025-01-15:** Decided to use pgvector instead of a separate vector DB. See [ADR-003].
- **2025-01-18:** Discovered rate-limit issue with GitHub API — added caching layer.
-->
