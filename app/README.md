# Chat frontend

React 19 + TypeScript chat UI for the Olist agent, built with Vite and Tailwind CSS v4. It supports questions and follow-ups, conversation history, inline charts with downloads, copy and retry, a mobile layout, and light and dark themes.

## Run locally

Requires Node.js 22+.

```bash
cd app
npm ci
npm run dev        # http://127.0.0.1:5173
```

The dev server proxies `/api` to a backend on `http://127.0.0.1:8000`. That backend is a FastAPI service that forwards questions to the Azure AI Foundry agent with Entra ID authentication.

## Scripts

| Command | Purpose |
|---|---|
| `npm run build` | Type-check and build for production |
| `npm test` | Unit tests (Vitest) |
| `npm run test:e2e` | Browser tests (Playwright) against a running app |
| `npm run format:check` | Prettier check |

## Structure

```
src/
  App.tsx            conversation state and layout
  api.ts             backend client
  history.ts         conversation history helpers (+ tests)
  components/        Composer, Sidebar, TurnView, Login, EmptyState, ThemeToggle
e2e/app.spec.ts      Playwright end-to-end tests
```
