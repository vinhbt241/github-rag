# System Overview

## Purpose

A retrieval system that helps developers search related GitHub issues and PRs. It is a **search tool**, not a Q&A chatbot — results are returned directly with source citations, no LLM generation.

## Architecture

```
GitHub API (PAT)
    │
    ▼
Fetcher (polling via cron job)
    │
    ▼
Normalizer
    │
    ▼
Chunker (multiple chunks per issue/PR)
    │
    ▼
Embedding Service (Qwen-Embedding V4, batched)
    │
    ▼
Vector Store (pgvector + PostgreSQL full-text search)
    │
    ▼
Retriever (hybrid search + RRF, top 20 chunks)
    │
    ▼
Parent Grouper (deduplicate by parent, max score, top 5)
    │
    ▼
Access Filter (project/repository permissions)
    │
    ▼
Web UI (search box + results)
```

Each stage has a single responsibility so components (embedding provider, vector database, search strategy) can be swapped without rewriting the system.

## Pipeline Stages

### Fetcher
- Polls GitHub API using a Personal Access Token (PAT).
- Weekly full sync via cron job; incremental sync using GitHub's `since` parameter to only fetch updated issues/PRs.
- Only merged PRs are indexed.
- Handles rate limits and API failures gracefully.

### Normalizer
- Converts raw GitHub API responses into a uniform internal format.
- Extracts relevant fields: title, body, comments, labels, URLs, state.

### Chunker
- Splits each issue/PR into multiple chunks:
  - **Body chunk**: title + body (always present)
  - **Comment chunks**: one per comment, filtering out comments shorter than ~20 characters
- Each chunk includes parent metadata (id, url, number, labels, project/repository).
- Prepares `embedding_text` with parent context prefix.

### Embedding Service
- Model: Qwen-Embedding (General Text Vector V4) via Qwen Cloud API, OpenAI-compatible format.
- Embeds chunks in batches for efficiency.
- Same model is used for both document embedding and query embedding.

### Vector Store
- PostgreSQL with pgvector extension.
- Stores embedding vectors + full-text search vectors (`tsvector`) on each chunk.
- See [data_model.md](data_model.md) for schema details.

## Background Processing

- **ActiveJob + Sidekiq**: async processing of sync and embedding jobs.
- **Cron job**: triggers weekly sync.

## Web UI

A simple web interface with a search box. Users type a question and receive ranked results with links back to the original GitHub issues and PRs.

## Scalability

- Target: ~10,000 issues.
- pgvector with `ivfflat` index handles this scale comfortably.
- Batched embedding keeps API costs and latency manageable during initial sync.

## MVP Scope

- Index one GitHub repository + one GitHub project.
- Fetch issues, PRs (merged only), and all comments.
- Schema supports multiple repos/projects from day one; MVP configures one of each.
- See [requirements.md](../product/requirements.md) for full MVP scope.
