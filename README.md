# Contract Table

AI-powered contract review and data extraction. Upload PDF or DOCX contracts, define the fields you care about, and let Claude extract the values — displayed in a live-updating table with inline editing, source highlighting, and export.

## Features

- **Bulk upload** — drag and drop multiple PDF or DOCX contracts at once
- **AI extraction** — powered by Claude (Anthropic); extracts 15 predefined fields out of the box
- **Custom fields** — add your own extraction questions in natural language
- **Live updates** — table cells populate in real time via Turbo Streams as extraction completes
- **Source highlighting** — click any cell to see the exact clause Claude used
- **PDF preview** — view the original document in a slide-over panel
- **Inline editing** — correct any extracted value directly in the table
- **Export** — download as CSV or Excel

## Tech stack

- [Ruby on Rails 8.1](https://rubyonrails.org/) — full-stack framework
- [Hotwire](https://hotwired.dev/) (Turbo + Stimulus) — real-time UI without a JS framework
- [Tailwind CSS](https://tailwindcss.com/) — styling
- [SQLite](https://www.sqlite.org/) — database (via Solid Queue / Solid Cache / Solid Cable)
- [Anthropic Claude](https://www.anthropic.com/) — AI extraction

---

## Local development

### Prerequisites

- Ruby 3.3+
- Bundler (`gem install bundler`)
- An [Anthropic API key](https://console.anthropic.com)

### Setup

```bash
git clone https://github.com/robinjfisher/contract-table.git
cd contract-table

bundle install

# Set your Anthropic API key (pick one approach):

# Option A — environment variable (recommended)
cp .env.example .env
# Edit .env and fill in ANTHROPIC_API_KEY

# Option B — Rails credentials
bin/rails credentials:edit
# Add: anthropic_api_key: sk-ant-...

bin/rails db:prepare
bin/dev
```

Open [http://localhost:3000](http://localhost:3000).

---

## Deployment

### Railway (easiest)

1. Push your repo to GitHub
2. Create a new Railway project → **Deploy from GitHub repo**
3. Add environment variables in Railway's dashboard:
   - `ANTHROPIC_API_KEY` — your Anthropic key
   - `RAILS_MASTER_KEY` — contents of `config/master.key`
4. Railway auto-detects the `Dockerfile` and builds automatically

Set a persistent volume mounted at `/rails/storage` for uploaded files and the SQLite database.

### Docker (self-hosted / GCP / AWS)

```bash
docker build -t contract-table .

docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  -v $(pwd)/storage:/rails/storage \
  --name contract-table \
  contract-table
```

#### GCP Cloud Run

```bash
gcloud builds submit --tag gcr.io/YOUR_PROJECT/contract-table

gcloud run deploy contract-table \
  --image gcr.io/YOUR_PROJECT/contract-table \
  --platform managed \
  --set-env-vars ANTHROPIC_API_KEY=sk-ant-...,RAILS_MASTER_KEY=... \
  --allow-unauthenticated
```

Mount a persistent disk or use Cloud SQL (PostgreSQL) for production data persistence.

#### AWS (ECS / App Runner)

1. Push the image to ECR
2. Set `ANTHROPIC_API_KEY` and `RAILS_MASTER_KEY` as ECS task environment variables or Secrets Manager secrets
3. Mount an EFS volume at `/rails/storage` for persistence

### Kamal (bare-metal / VPS)

Edit `.kamal/deploy.yml` with your server details, then:

```bash
gem install kamal
kamal setup
kamal deploy
```

---

## Configuration

| Variable | Required | Description |
|---|---|---|
| `ANTHROPIC_API_KEY` | Yes | Anthropic API key — get one at console.anthropic.com |
| `RAILS_MASTER_KEY` | Yes (production) | Decrypts `config/credentials.yml.enc` |
| `SECRET_KEY_BASE` | No | Overrides Rails secret key (alternative to master key) |
| `JOB_CONCURRENCY` | No | Background job worker processes (default: 1) |

---

## Security

- `config/master.key` is excluded from version control by `.gitignore` — never commit it
- Credentials are stored in `config/credentials.yml.enc` (encrypted, safe to commit)
- All API keys should be provided via environment variables in production

---

## Contributing

Pull requests welcome. Please open an issue first for significant changes.

## License

MIT
