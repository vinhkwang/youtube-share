# YShare — YouTube Video Sharing App

A full-stack video sharing platform built with **Ruby on Rails 7** (API) and **React**. Users can register, share YouTube videos, and see real-time notifications when others share videos — powered by ActionCable WebSockets.

---

## Features

- **JWT Authentication** — register, login, persistent sessions via localStorage
- **Share YouTube Videos** — paste any YouTube URL; title and thumbnail are fetched automatically via oEmbed (no API key needed)
- **Real-time Notifications** — toast banners appear instantly for all connected users when a video is shared (ActionCable)
- **Paginated Video Feed** — newest-first feed with pagination
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
| Schema Management | Ridgepole |
| Tests | RSpec, FactoryBot, shoulda-matchers |

---

## Prerequisites

- Ruby 3.2.2 ([rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io))
- Node 18+ ([nvm](https://github.com/nvm-sh/nvm) recommended)
- PostgreSQL 15
- Docker + Docker Compose (optional)

---

## Local Development Setup

### 1. Clone the repo

```bash
git clone https://github.com/vinhkwang/youtube-share.git
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

Open two terminals:

```bash
# Terminal 1 — Rails API (port 5000)
cd backend
bundle exec rails server -p 5000

# Terminal 2 — React dev server (port 3000)
cd frontend
npm run dev
```

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
