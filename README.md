# 💸 Smart Finance App

Full-stack personal finance application: **Flutter** mobile client and **Node.js** REST API backed by **PostgreSQL**. Register, sign in, and manage expenses end-to-end.

**Status:** MVP — functional auth and expense CRUD; UI and store readiness are ongoing.

---

## Table of contents

- [Tech stack](#tech-stack)
- [Screenshots](#screenshots)
- [Repository layout](#repository-layout)
- [Features](#features)
- [API overview](#api-overview)
- [Environment variables](#environment-variables)
- [Getting started](#getting-started)
- [Roadmap](#roadmap)
- [Author](#author)

---

## Tech stack

| Layer | Details |
|--------|---------|
| **Mobile** | Flutter, Clean Architecture (domain / data / presentation), **Riverpod** (state), **GoRouter** (navigation), **Dio** (HTTP), **flutter_secure_storage** (tokens) |
| **Backend** | Node.js, **Express**, **PostgreSQL** (`pg`), **JWT** auth, **bcrypt**, Helmet, CORS, Morgan |
| **API** | REST, JSON |

---

## Screenshots

<!-- Add 2–4 screenshots: login, expense list, add/edit expense. Replace paths when assets exist. -->

| | |
|:--:|:--:|
| *Login* | *Expense list* |
| ![Login](docs/screenshots/login.png) | ![Expenses](docs/screenshots/expenses.png) |

*Placeholder: create `docs/screenshots/` and drop images here, or remove this table until you have assets.*

---

## Repository layout

```
smart-finance-app/
├── backend/          # Express API (PostgreSQL, JWT)
├── mobile/app/       # Flutter application
└── docs/             # Documentation and assets (e.g. screenshots)
```

---

## Features

- **Authentication** — Register and login; JWT issued on login; tokens stored securely on device.
- **Expenses** — List expenses (with optional query filters); create, update, and delete (authenticated).
- **Architecture** — Separation of domain, data, and presentation layers for maintainability.
- **Health checks** — `GET /health` and `GET /db-test` for server and database connectivity (development/ops).

---

## API overview

Base path: `/api` (server default: port **5000**).

| Area | Method | Path | Auth |
|------|--------|------|------|
| Health | `GET` | `/health` | No |
| DB check | `GET` | `/db-test` | No |
| Register | `POST` | `/api/auth/register` | No |
| Login | `POST` | `/api/auth/login` | No |
| List expenses | `GET` | `/api/expenses` | Bearer JWT |
| Create expense | `POST` | `/api/expenses` | Bearer JWT |
| Update expense | `PUT` | `/api/expenses/:id` | Bearer JWT |
| Delete expense | `DELETE` | `/api/expenses/:id` | Bearer JWT |

Protected routes expect: `Authorization: Bearer <token>`.

---

## Environment variables

Create a **`backend/.env`** file (do not commit secrets). The API uses:

| Variable | Purpose |
|----------|---------|
| `PORT` | HTTP port (default `5000` if omitted) |
| `JWT_SECRET` | Secret for signing and verifying JWTs |
| `DB_HOST` | PostgreSQL host |
| `DB_PORT` | PostgreSQL port |
| `DB_USER` | Database user |
| `DB_PASSWORD` | Database password |
| `DB_NAME` | Database name |

**Mobile:** API base URL is set in `mobile/app/lib/core/constants/app_constants.dart` (default targets Android emulator `10.0.2.2:5000`; adjust for iOS simulator or physical devices).

---

## Getting started

### Prerequisites

- Node.js and npm  
- PostgreSQL instance and empty database matching your `.env`  
- Flutter SDK (see `mobile/app` for SDK constraints in `pubspec.yaml`)

### Backend

```bash
cd backend
npm install
# Configure .env (see Environment variables)
npm run dev
```

Production-style start: `npm start` (runs `node app.js`).

### Mobile

```bash
cd mobile/app
flutter pub get
flutter run
```

Ensure the backend is running and the base URL in `app_constants.dart` matches your environment (emulator vs simulator vs LAN IP).

---

## Roadmap

- AI-based expense insights  
- Charts and analytics  
- Subscription model  
- Notifications  

---

## Author

**Santiago Castañares**

Portfolio project; under active development.
