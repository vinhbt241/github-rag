# Product Requirements

## Problem Statement

Developers need to find related GitHub issues and PRs but GitHub's built-in search is limited. This system helps them:

- Find previous bugs similar to the current bug.
- Answer questions about why a feature was implemented.
- Find discussions and architecture decisions.

## Target Users

Developers.

## Example Questions

- "Has anyone fixed OAuth timeout before?"
- "Why did we decide to move the gateway database into the `app` project?"
- "Find the architecture design of the Variant model."

## Data Indexed

GitHub objects:
- Issues (title, body, comments, labels, url, project)
- Pull requests — merged only (title, body, review comments, labels, url, repository)

Closed issues remain searchable — historical context is valuable.

## MVP Scope

- Index one GitHub repository + one GitHub project.
- Fetch issues, merged PRs, and all comments.
- Split each issue/PR into multiple chunks (body + one chunk per comment, filter low-value comments).
- Store embeddings in PostgreSQL using pgvector.
- Hybrid search: PostgreSQL full-text search + vector similarity, merged via RRF.
- Return top 5 most relevant parent documents (issues/PRs), grouped from chunk-level results.
- Always include links back to the original GitHub issues and PRs.
- Polling-based sync via cron job (weekly).
- No LLM generation — return ranked results with citations directly.
- Access control: filter by project/repository based on user permissions.
- Background jobs: ActiveJob + Sidekiq.
- Web UI with a search box.

### Post-MVP Improvements

- Reranking
- Code diffs as chunks
- Additional search strategies beyond semantic search
- True BM25 (via pgroonga or similar)
- Sophisticated evaluation pipeline
- GitHub App authentication (replace PAT)

## Security

Users should only see:
- Pull requests: from repositories they have access to.
- Issues: from projects they have access to.

**Implementation**: Store `repository` on PR chunks, `project` on issue chunks. Check user's access permissions at query time and filter results accordingly.

## Source Citations

Results always include:
```
Issue #421
PR #812
Repository: acme/gateway
https://github.com/acme/gateway/issues/421
```

## Failure Modes

| Failure | Handling |
|---------|----------|
| Duplicate issues | Validate in DB (unique on `github_id`) |
| Renamed repositories | If repo name changes, update PR chunk `repository` field. Query PRs by `repository_id` FK. |
| Deleted PRs | Keep embedding if the PR URL still resolves; remove if it returns 404. |
| Force pushes | Only merged PRs are indexed — not a concern. |
| Edited comments | Re-embed the entire parent document (all chunks). |
| Rate limits | Respect GitHub API rate limit headers; retry with backoff. |
| GitHub API failures | Retry with exponential backoff; log failures in `sync_logs`. |

## Evaluation

Build evaluation dataset manually after the vector DB is functional.

**Dataset format:**
```
Question
Expected issue
Expected PR
```

**Metrics:**
- Recall@5
- Recall@10
- MRR (Mean Reciprocal Rank)
- nDCG (Normalized Discounted Cumulative Gain)
