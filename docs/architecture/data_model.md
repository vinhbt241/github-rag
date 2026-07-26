# Data Model

## ER Diagram

```
repositories ───────┐
                    ├── pull_requests ─── chunks
github_projects ────┤
                    ├── issues ────────── chunks
                    │
sync_logs ──────────┘ (polymorphic: repository | github_project)
```

## Tables

### repositories

Stores tracked GitHub repositories. MVP targets 1, schema supports many.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| name | string | NOT NULL | e.g., "gateway" |
| full_name | string | NOT NULL, UNIQUE | e.g., "acme/gateway" |
| github_id | integer | NOT NULL, UNIQUE | GitHub's internal repo ID |
| last_synced_at | datetime | | Last successful sync timestamp; used as `since` param for incremental sync |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

### github_projects

GitHub Projects (v2) used for issue tracking. MVP targets 1, schema supports many.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| title | string | NOT NULL | e.g., "Gateway Migration" |
| number | integer | NOT NULL | Project number |
| owner | string | NOT NULL | Org or user who owns the project |
| github_node_id | string | NOT NULL, UNIQUE | GraphQL node ID |
| last_synced_at | datetime | | Last successful sync timestamp |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

### issues

Parent records for GitHub issues.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| github_project_id | FK → github_projects | NOT NULL | |
| number | integer | NOT NULL | Issue number |
| github_id | integer | NOT NULL, UNIQUE | GitHub's internal issue ID |
| title | string | NOT NULL | |
| body | text | | Issue body (markdown) |
| state | string | NOT NULL | "open" / "closed" |
| labels | string[] | NOT NULL, DEFAULT [] | Array of label names |
| url | string | NOT NULL | Direct GitHub URL |
| github_updated_at | datetime | NOT NULL | GitHub's `updated_at`; used to detect changes |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

**Indexes:**
- `unique index on (github_project_id, number)`
- `index on github_updated_at` (incremental sync queries)

### pull_requests

Parent records for GitHub pull requests. Only merged PRs are stored.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| repository_id | FK → repositories | NOT NULL | |
| number | integer | NOT NULL | PR number |
| github_id | integer | NOT NULL, UNIQUE | GitHub's internal PR ID |
| title | string | NOT NULL | |
| body | text | | PR body (markdown) |
| state | string | NOT NULL | "merged" (only merged PRs are indexed) |
| labels | string[] | NOT NULL, DEFAULT [] | Array of label names |
| url | string | NOT NULL | Direct GitHub URL |
| merged_at | datetime | | |
| github_updated_at | datetime | NOT NULL | GitHub's `updated_at`; used to detect changes |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

**Indexes:**
- `unique index on (repository_id, number)`
- `index on github_updated_at`

### chunks

Individual chunks that get embedded and searched. Each chunk belongs to a parent (issue or PR).

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| chunkable_type | string | NOT NULL | "Issue" or "PullRequest" (polymorphic) |
| chunkable_id | bigint | NOT NULL | FK to issues.id or pull_requests.id |
| chunk_type | string | NOT NULL | "body" or "comment" |
| source_github_id | integer | | GitHub comment ID for comment chunks; null for body chunks |
| title | string | | Parent title (denormalized for query convenience) |
| parent_url | string | NOT NULL | Parent's GitHub URL (denormalized) |
| parent_number | integer | NOT NULL | Parent's issue/PR number |
| content | text | NOT NULL | Raw chunk text (without context prefix) |
| embedding_text | text | NOT NULL | Text sent to embedding model (includes parent context prefix) |
| embedding | vector(1024) | | Embedding vector; dimension matches Qwen-Embedding V4 output |
| search_vector | tsvector | | PostgreSQL full-text search vector |
| repository | string | | Parent's repo full_name; set for PR chunks |
| project | string | | Parent's project title; set for issue chunks |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

**Indexes:**
- `index on (chunkable_type, chunkable_id)` (lookup chunks for a parent)
- `index on (repository)` (access filtering)
- `index on (project)` (access filtering)
- `GIN index on search_vector` (full-text search)
- `ivfflat index on embedding` with `vector_cosine_ops` (vector similarity search)

### sync_logs

Tracks sync runs for monitoring and debugging.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| syncable_type | string | NOT NULL | "Repository" or "GithubProject" (polymorphic) |
| syncable_id | bigint | NOT NULL | FK to repositories.id or github_projects.id |
| started_at | datetime | NOT NULL | |
| finished_at | datetime | | |
| status | string | NOT NULL | "running" / "completed" / "failed" |
| items_fetched | integer | DEFAULT 0 | |
| items_created | integer | DEFAULT 0 | |
| items_updated | integer | DEFAULT 0 | |
| error_message | text | | Populated when status = "failed" |
| created_at | datetime | NOT NULL | |

**Indexes:**
- `index on (syncable_type, syncable_id)` (recent logs for a repo/project)

## Required Extensions

```sql
CREATE EXTENSION IF NOT EXISTS vector;    -- pgvector for vector similarity search
```

## Embedding Text Format

The `embedding_text` column stores the text actually sent to the embedding model. It includes parent context so the model understands what each chunk is about.

- **Body chunk**: `"[Issue #421 in acme/gateway] OAuth timeout during login\n\nWhen a user tries to log in..."`
- **Comment chunk**: `"[Comment on Issue #421: OAuth timeout during login] I had the same problem. The root cause was..."`

The `content` column stores the raw text without the prefix, used for display.

## Notes

- The vector dimension (`1024`) should match the output dimension of Qwen-Embedding (General Text Vector V4). Verify this before creating the index.
- The `ivfflat` index is created **after** data is loaded (it requires existing rows to build centroids). During development, skip this index until you have a few hundred chunks.
- PR chunks store `repository`, issue chunks store `project`. This enables access filtering at query time.
- `labels` uses PostgreSQL native array type (`text[]`) rather than a join table, since labels are only used for display/filtering and don't need to be queried relationally.
