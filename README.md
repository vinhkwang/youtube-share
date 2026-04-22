# YShare — YouTube Video Sharing App

A full-stack video sharing platform built with **Ruby on Rails 7** (API) and **React**. Users can register, share YouTube videos, and see real-time notifications when others share videos — powered by ActionCable WebSockets.

---

## Features

- **JWT Authentication** — register, login, persistent sessions via localStorage
- **Share YouTube Videos** — paste any YouTube URL; title and thumbnail are fetched automatically via oEmbed (no API key needed)
- **Real-time Notifications** — toast banners appear instantly for all connected users when a video is shared (ActionCable)
- **Paginated Video Feed** — newest-first feed with pagination
- **Background Jobs** — Sidekiq + Redis for async processing
- **Declarative Schema** — Ridgepole manages the DB schema (no migration files)
- **Docker-ready** — single `docker-compose up --build` to run everything

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18, React Router v6, Axios, Tailwind CSS v4 |
| Backend | Ruby on Rails 7.1 (API mode) |
| Database | PostgreSQL 15 |
| Real-time | ActionCable (WebSockets) |
| Auth | JWT (`jwt` gem) + bcrypt (`has_secure_password`) |
| Background Jobs | Sidekiq + Redis 7 |
| Schema Management | Ridgepole |
| Tests | RSpec, FactoryBot, shoulda-matchers |

---

## Prerequisites

- Ruby 3.2.2 ([rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io))
- Node 18+ ([nvm](https://github.com/nvm-sh/nvm) recommended)
- PostgreSQL 15
- Redis 7 (optional for local dev — see note below)
- Docker + Docker Compose (optional)

---

## Local Development Setup

### 1. Clone the repo

```bash
git clone <your-repo-url>
cd youtube-share
```

### 2. Backend setup

```bash
cd backend
bundle install
```

Copy and fill in the environment file:

```bash
cp .env.example .env
```

Edit `.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=your_postgres_user
DB_PASSWORD=your_postgres_password
DB_NAME=youtube_sharing_development

REDIS_URL=redis://localhost:6379
FRONTEND_URL=http://localhost:3000
CABLE_URL=ws://localhost:5000/cable
```

### 3. Database setup

```bash
# Create the database
bundle exec rails db:create

# Apply schema via Ridgepole (replaces db:migrate)
bundle exec rails ridgepole:apply
```

### 4. Frontend setup

```bash
cd ../frontend
npm install
cp .env.example .env
```

The defaults in `.env` work out of the box:

```env
VITE_API_URL=http://localhost:5000
VITE_CABLE_URL=ws://localhost:5000/cable
```

---

## Running Locally

Open three terminals:

```bash
# Terminal 1 — Rails API (port 5000)
cd backend
bundle exec rails server -p 5000

# Terminal 2 — React dev server (port 3000)
cd frontend
npm run dev

# Terminal 3 — Sidekiq (optional, for background jobs)
cd backend
bundle exec sidekiq
```

> **Note:** Redis is only required if you use the `redis` ActionCable adapter or Sidekiq. For local dev, `cable.yml` defaults to the `async` adapter so Redis is not needed.

Visit `http://localhost:3000`.

---

## Running with Docker

```bash
# From the project root
docker-compose up --build
```

| Service | URL |
|---|---|
| Frontend | http://localhost:3000 |
| Backend API | http://localhost:5000 |
| Sidekiq UI | http://localhost:5000/sidekiq |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |

The backend automatically creates the database and applies the schema on first start.

To stop:

```bash
docker-compose down

# To also remove volumes (wipes DB data)
docker-compose down -v
```

---

## Schema Management (Ridgepole)

This project uses **Ridgepole** instead of Rails migrations. Schema is defined in `db/schemas/`.

```bash
# Apply schema to current environment
bundle exec rails ridgepole:apply

# Preview changes without touching the DB
bundle exec rails ridgepole:dry_run

# Export current DB state to Schemafile format
bundle exec rails ridgepole:export

# Create DB + apply schema in one command
bundle exec rails ridgepole:apply_all
```

To modify the schema, edit `db/schemas/users.rb` or `db/schemas/videos.rb`, then run `ridgepole:apply`.

---

## API Reference

### Auth

| Method | Endpoint | Auth | Body | Response |
|---|---|---|---|---|
| `POST` | `/api/v1/auth/register` | No | `{ email, username, password, password_confirmation }` | `{ user, token }` |
| `POST` | `/api/v1/auth/login` | No | `{ email, password }` | `{ user, token }` |
| `GET` | `/api/v1/auth/me` | Bearer token | — | `{ user }` |

### Videos

| Method | Endpoint | Auth | Notes |
|---|---|---|---|
| `GET` | `/api/v1/videos?page=1` | No | Paginated, newest first |
| `GET` | `/api/v1/videos/:id` | No | Single video |
| `POST` | `/api/v1/videos` | Bearer token | `{ youtube_url }` — fetches metadata automatically |

All authenticated requests require the header:
```
Authorization: Bearer <token>
```

---

## Running Tests

```bash
cd backend

# Set up the test database
RAILS_ENV=test bundle exec rails db:create ridgepole:apply

# Run all specs
bundle exec rspec

# Run specific suites
bundle exec rspec spec/models/
bundle exec rspec spec/requests/
bundle exec rspec spec/services/
```

---

## Project Structure

```
youtube-share/
├── docker-compose.yml
├── backend/
│   ├── app/
│   │   ├── channels/
│   │   │   └── notifications_channel.rb
│   │   ├── controllers/api/v1/
│   │   │   ├── auth_controller.rb
│   │   │   └── videos_controller.rb
│   │   ├── models/
│   │   │   ├── user.rb
│   │   │   └── video.rb
│   │   └── services/
│   │       ├── json_web_token.rb
│   │       ├── youtube_url_extractor.rb
│   │       └── youtube_metadata_fetcher.rb
│   ├── db/
│   │   ├── Schemafile
│   │   └── schemas/
│   │       ├── users.rb
│   │       └── videos.rb
│   └── spec/
│       ├── models/
│       ├── requests/
│       └── services/
└── frontend/
    └── src/
        ├── components/
        │   ├── Header.jsx
        │   ├── VideoCard.jsx
        │   ├── NotificationBanner.jsx
        │   └── ShareModal.jsx
        ├── context/AuthContext.jsx
        ├── hooks/useActionCable.js
        ├── pages/
        │   ├── Home.jsx
        │   ├── Login.jsx
        │   └── Register.jsx
        └── services/api.js
```

---

## Troubleshooting

**`fe_sendauth: no password supplied`**
→ `dotenv-rails` gem is not loading your `.env`. Run `bundle install` and restart the Rails server.

**`cannot load such file -- db/schemas/users`**
→ Schema files must have `.rb` extension, not `.schema`. They are already named correctly in this project.

**Frontend shows "Failed to load videos"**
→ The Rails backend is not running. Start it with `bundle exec rails server -p 5000`.

**No real-time notifications appearing**
→ Check: (1) Rails server is running, (2) `cable.yml` adapter is `async` for local dev (no Redis needed), (3) browser console for WebSocket connection errors.

**`Cannot find native binding` error in WSL**
→ `node_modules` was installed on Windows but you're running in WSL. Delete `node_modules` and `package-lock.json`, then run `npm install` from within WSL using Node 20+.
