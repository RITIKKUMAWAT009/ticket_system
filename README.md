# Ticket Management System

A production-quality demo/MVP ticket (complaint) management system for ~100 users, architected to scale to 10,000+ users.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x, Riverpod, Go Router, Clean Architecture |
| Backend | Node.js, Express, Prisma ORM, PostgreSQL |
| Auth | OTP + JWT (15min access / 7day refresh) |
| Notifications | Firebase Cloud Messaging (FCM) |
| Deployment | Render (API), Supabase (DB), Cloudflare Pages (Web) |

## User Roles

- **Citizen** — Register, login via OTP, create/view tickets, add comments, receive notifications
- **Support Agent** — View assigned tickets, change status, add comments
- **Admin** — Manage districts/tehsils/projects, assign tickets, view analytics

## Project Structure

```
ticket_sys_workspace/
├── backend/                  # Express REST API
│   ├── prisma/
│   │   ├── schema.prisma     # Database schema
│   │   ├── seed.js           # Prisma seed script
│   │   └── seed.sql          # Raw SQL seed
│   ├── src/
│   │   ├── config/           # App config, Swagger
│   │   ├── middleware/       # Auth, upload, error handling
│   │   ├── modules/            # Feature-based modules
│   │   │   ├── auth/
│   │   │   ├── master-data/
│   │   │   ├── tickets/
│   │   │   └── notifications/
│   │   └── utils/            # JWT, captcha, FCM, logger
│   └── tests/                # Unit & integration tests
├── frontend/                 # Flutter app
│   └── lib/
│       ├── core/             # Config, network, theme, router
│       └── features/         # auth, tickets, admin, agent, notifications
├── docs/
│   └── API.md                # REST API documentation
└── docker-compose.yml        # Local dev environment
```

## Quick Start (Local Development)

### Prerequisites

- Node.js 18+
- Docker & Docker Compose
- Flutter 3.x (for frontend)

### 1. Start Database & API

```bash
# Clone and enter project
cd ticket_sys_workspace

# Start PostgreSQL and API via Docker
docker compose up -d postgres

# Setup backend
cd backend
cp .env.example .env
npm install
npx prisma generate
npx prisma db push
npm run db:seed
npm run dev
```

API runs at `http://localhost:3000`
Swagger docs at `http://localhost:3000/api-docs`

### 2. Start Flutter Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

For Android emulator:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

### 3. Seed Users (for testing)

| Role | Mobile | Notes |
|------|--------|-------|
| Admin | 9999999999 | Pre-seeded |
| Agent | 8888888888 | Pre-seeded |
| Citizen | 9876543210 | Pre-seeded |

OTP is logged to the API console in development mode.

## Environment Variables

See `backend/.env.example` for all backend variables:

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `JWT_ACCESS_SECRET` | Access token signing secret |
| `JWT_REFRESH_SECRET` | Refresh token signing secret |
| `FCM_DISABLED` | Set `true` to skip FCM in dev |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | Path to Firebase service account JSON |

## Running Tests

```bash
cd backend
npm test
```

## Docker (Full Stack)

```bash
docker compose up --build
```

## Deployment

### Backend (Render)

1. Connect GitHub repo to Render
2. Set build command: `cd backend && npm install && npx prisma generate`
3. Set start command: `cd backend && npx prisma migrate deploy && node src/server.js`
4. Add environment variables from `.env.example`
5. Set `DATABASE_URL` to Supabase PostgreSQL connection string

### Database (Supabase)

1. Create a free Supabase project
2. Copy the PostgreSQL connection string (use "Transaction" pooler for serverless)
3. Run migrations: `npx prisma migrate deploy`
4. Seed: `npm run db:seed`

### Frontend (Cloudflare Pages)

```bash
cd frontend
flutter build web --dart-define=API_BASE_URL=https://your-api.onrender.com/api
```

Deploy the `build/web` directory to Cloudflare Pages.

## API Endpoints

See [docs/API.md](docs/API.md) for full REST API documentation.

Key endpoints:
- `POST /api/auth/register` — Citizen registration
- `POST /api/auth/send-otp` → `POST /api/auth/verify-otp` — Login flow
- `GET /api/districts` → tehsils → projects — Master data cascade
- `POST /api/tickets` — Create complaint with attachments
- `GET /api/notifications` — In-app notifications

## TODO / Open Questions

The following items need stakeholder clarification (marked with TODO in code):

1. **Ticket assignment field** — Schema lacks `assignedAgentId`; added as TODO field for agent assignment workflow
2. **Profile image upload** — Optional registration field; storage backend not specified
3. **Agent listing API** — Admin ticket assignment needs a dropdown of agents (no API defined)
4. **SMS gateway** — OTP is generated and stored; actual SMS delivery provider not specified
5. **PDF user manual** — `ticketing.pdf` was not available; requirements taken from specification text
6. **Reports screen** — Analytics API provided; detailed report formats not specified

## License

Demo/MVP — Internal use only.
