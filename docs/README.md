# Github RAG design documents

This document was used to explore requirements and make design decisions. The finalized decisions have been migrated into:

- [Product Requirements](product/requirements.md) — problem statement, users, MVP scope, security, failure modes, evaluation
- [Retrieval Strategy](product/retrieval.md) — hybrid search, RRF, chunking, retrieval pipeline, chunk text composition
- [System Overview](architecture/system_overview.md) — architecture diagram, pipeline stages, background processing, scalability
- [Data Model](architecture/data_model.md) — database schema, indexes, embedding text format

## Key Decisions

| Decision | Choice |
|----------|--------|
| Chunking | Multiple chunks per issue/PR (body + one per comment, filter short comments) |
| Score merging | Reciprocal Rank Fusion (RRF), configurable `k` (default 60) |
| Parent scoring | Max of child chunks' RRF scores |
| Retrieval flow | Top 20 chunks per search method → RRF merge → group by parent → top 5 parents |
| Embedding text | Parent context prefix on every chunk |
| Sync | Weekly cron + incremental (GitHub `since` param) |
| On change | Re-embed entire parent document |
| FTS | PostgreSQL built-in `tsvector`/`tsquery` (migrate to BM25 later if needed) |
| Embedding model | Qwen-Embedding (General Text Vector V4) via Qwen Cloud (OpenAI-compatible API) |
| Generation model | None — return results directly |
| Interface | Web UI with search box |
| Background jobs | ActiveJob + Sidekiq |
| GitHub auth | PAT (MVP), schema supports GitHub App later |
| Access control | Store `repository` on PR chunks, `project` on issue chunks; filter at query time |
