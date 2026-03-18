# Dashboard: Options, Cost, and Implementation

This directory contains dashboard implementation code and documentation for the microparticles_saint_john project. The goal is to provide an accessible, interactive interface for partner organizations and researchers to explore microparticle data across the Wolastoq/Saint John River watershed.

---

## Contents

| Path | Description |
|------|-------------|
| `react/App.jsx` | React (JavaScript) dashboard framework |
| `react/README.md` | React setup and deployment instructions |
| `streamlit/app.py` | Streamlit (Python) dashboard framework |
| `streamlit/README.md` | Streamlit setup and deployment instructions |

---

## Framework Comparison

Two frameworks were evaluated for this project: **React** (JavaScript) and **Streamlit** (Python).

### Streamlit

**Best for:** Rapid prototyping, researcher-facing tools, Python-native teams.

| Factor | Assessment |
|--------|------------|
| Setup time | Very fast — `pip install streamlit && streamlit run app.py` |
| Language | Python — consistent with analysis pipeline |
| Hosting | Streamlit Community Cloud (free tier available), or any cloud VM |
| Cost | Free for public apps; ~$250–500/month for private enterprise hosting |
| Interactivity | Moderate — widgets, filters, maps, charts all supported |
| Stakeholder accessibility | High — shareable URL, no technical setup for end users |
| Learning curve | Low for Python users; very low compared to React |
| Limitations | Slower re-renders for complex UIs; less design flexibility than React |

**Recommendation for this project:** Streamlit is the best starting point. The data pipeline is Python-based, partner organizations need a low-barrier access tool, and the dataset size does not require a high-performance frontend.

---

### React

**Best for:** Production-grade web applications, complex interactivity, public-facing tools with design requirements.

| Factor | Assessment |
|--------|------------|
| Setup time | Moderate — requires Node.js, npm, component architecture |
| Language | JavaScript/JSX — separate from Python analysis pipeline |
| Hosting | Vercel, Netlify (free tier), AWS Amplify, or S3 static hosting |
| Cost | Free–$20/month for most hosting scenarios |
| Interactivity | Very high — full control over UI, real-time updates, custom maps |
| Stakeholder accessibility | High once deployed; complex to set up locally |
| Learning curve | High — JSX, state management, API integration, build tooling |
| Limitations | Significant development overhead for a research dataset; AWS SDK for JS required to call DynamoDB directly or requires a backend API |

**Recommendation for this project:** React is appropriate if the dashboard needs to scale to a public-facing tool or requires a polished design. For the current phase, it adds unnecessary complexity.

---

## Schema Considerations for Dashboard Development

DynamoDB is a NoSQL database that does not support native SQL-style JOINs. This affects how the dashboard retrieves and displays data.

**Key design decisions:**

1. **Global Secondary Indexes (GSIs)** on `site_id` in Water, Sediment, and Animal tables allow efficient lookup of all samples at a given site without scanning the full table.

2. **Client-side joining:** For the dashboard, joined views (e.g., site metadata alongside sample data) are assembled in Python (Streamlit) or JavaScript (React) by making multiple targeted queries and merging in memory. This is appropriate at the current data scale.

3. **Caching:** Streamlit's `@st.cache_data` decorator should be used on all DynamoDB fetch functions to avoid repeated API calls during user interactions. React dashboards should cache fetched data in component state or a context provider.

4. **Access patterns to support in the dashboard:**
   - Filter by waterbody / site
   - Filter by sample type (water, sediment, animal)
   - Filter by polymer type or confirmation status (FTIR data)
   - Map view of site locations with microparticle concentration
   - Table view with downloadable CSV export

---

## Stakeholder Accessibility Notes

The partner network for this project spans academic institutions, NGOs, and Indigenous community groups with varying levels of technical capacity. Dashboard design should prioritize:

- **No login required** for read-only access (public data only)
- **Plain-language labels** on all filters and chart axes — avoid field names like `sample_id` or `ftir_id` in the UI
- **Mobile-friendly layout** — Streamlit and React both support responsive design
- **CSV export** — partners need to be able to download filtered datasets
- **Map-first layout** — geographic context is central to the project's framing around the watershed

---

## Cost Summary

| Scenario | Estimated Monthly Cost |
|----------|------------------------|
| Streamlit Community Cloud (public app) | Free |
| Streamlit Community Cloud (private/team) | ~$250–500/month |
| React on Vercel/Netlify (static) | Free–$20/month |
| DynamoDB reads (PAY_PER_REQUEST, low volume) | < $1/month |
| DynamoDB reads (moderate dashboard traffic) | $5–25/month |

For the current project scope — a small research dataset accessed by a defined partner network — hosting costs are negligible. The primary cost consideration is DynamoDB read operations, which at PAY_PER_REQUEST pricing remain very low unless the dashboard is accessed thousands of times per day.