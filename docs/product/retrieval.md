# Retrieval Strategy

## Overview

The system uses **hybrid search** — combining vector similarity with full-text search — and merges results via **Reciprocal Rank Fusion (RRF)**. There is no LLM generation step; retrieval results are returned directly to the user.

## Search Methods

### Vector Search
- Embed the user's query using the same model as document embeddings (Qwen-Embedding / General Text Vector V4).
- Compute cosine similarity between query vector and all chunk vectors in pgvector.
- Return top 20 chunks ranked by similarity.

### Full-Text Search
- Convert the user's query into a PostgreSQL `tsquery`.
- Match against each chunk's `search_vector` (`tsvector`) using `ts_rank`.
- Return top 20 chunks ranked by `ts_rank`.

> **Note**: PostgreSQL's built-in FTS uses a TF-IDF-like algorithm, not true BM25. This is sufficient for MVP. Migrate to true BM25 (e.g., pgroonga) later if needed.

## Score Merging: Reciprocal Rank Fusion (RRF)

RRF combines ranked lists without requiring score normalization.

```
RRF_score(chunk) = Σ 1 / (k + rank_i)
```

Where:
- The sum is over each ranking list (vector and FTS).
- `rank_i` is the chunk's rank (1-indexed) in list `i`.
- `k` is a configurable parameter (default: 60).

If a chunk appears in only one list, it gets a single term. If it appears in both, scores add up, rewarding documents that are relevant by both measures.

## Retrieval Pipeline

1. **Embed query** — same model as document embeddings (Qwen-Embedding / General Text Vector V4).
2. **Vector search** — top 20 chunks by cosine similarity.
3. **FTS search** — top 20 chunks by `ts_rank`.
4. **Merge via RRF** — combine both ranked lists into one unified ranking.
5. **Parent grouping** — group chunks by parent issue/PR. Parent score = **max** of its chunks' RRF scores.
6. **Deduplicate** — return top 5 unique parents.
7. **Access filter** — remove parents the user doesn't have permission to see (based on `repository` / `project` metadata).
8. **Return results** — with source citations and GitHub links.

## Chunking Strategy

Each issue/PR is split into multiple chunks:

| Chunk type | Source | Filter |
|------------|--------|--------|
| Body | Issue/PR title + body | Always included |
| Comment | Individual issue comment or PR review comment | Skip comments shorter than ~20 characters |

One chunk per comment. Low-value comments (short replies like "+1", "LGTM") are filtered out.

## Chunk Text Composition

Each chunk's `embedding_text` includes parent context so the embedding model understands what the chunk is about.

- **Body chunk**: `"[Issue #421 in acme/gateway] OAuth timeout during login\n\nWhen a user tries to log in..."`
- **Comment chunk**: `"[Comment on Issue #421: OAuth timeout during login] I had the same problem. The root cause was..."`

The raw comment text (without prefix) is stored separately in `content` for display purposes.

## Re-embedding Policy

When an issue or PR changes (new comments, edited body, label change):
- **Re-embed the entire parent document** (all its chunks).
- Simpler than partial updates.
- Acceptable cost at ~10,000 issues scale.

## Configuration

| Parameter | Default | Notes |
|-----------|---------|-------|
| `rrf_k` | 60 | RRF smoothing constant. Higher values compress score differences. |
| `vector_top_k` | 20 | Number of chunks from vector search. |
| `fts_top_k` | 20 | Number of chunks from FTS search. |
| `result_top_k` | 5 | Number of parent documents returned to the user. |
| `min_comment_length` | 20 | Minimum characters for a comment to become a chunk. |
