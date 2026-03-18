# Dashboard — React

Production-grade web dashboard built with React (JavaScript).

Appropriate if the dashboard needs to scale to a public-facing tool or requires a polished design beyond what Streamlit provides. See `../README.md` for a full comparison of the two frameworks.

---

## Setup

```bash
npm create vite@latest microparticles-dashboard -- --template react
cd microparticles-dashboard
npm install recharts
```

Replace `src/App.jsx` with the `App.jsx` file in this directory.

```bash
npm run dev
```

Opens at `http://localhost:5173`.

## Important — DynamoDB access from React

DynamoDB **cannot be called directly from a browser frontend** without exposing AWS credentials. The `App.jsx` file expects a backend API at `YOUR_API_BASE_URL` that wraps the boto3 queries from `../../database/data_extraction.py`.

Options for the backend:
- **AWS Lambda + API Gateway** — serverless, scales automatically, pay-per-request
- **FastAPI or Flask** — simple Python server wrapping the existing extraction functions
- **Pre-exported JSON/CSV** — skip the backend entirely by serving static data files

For rapid prototyping without a backend, use the Streamlit app instead.

## Deployment

Static hosting (once a backend API is in place):

```bash
npm run build   # produces dist/ folder
```

Deploy `dist/` to **Vercel**, **Netlify**, or **AWS S3 + CloudFront** (free–$20/month).