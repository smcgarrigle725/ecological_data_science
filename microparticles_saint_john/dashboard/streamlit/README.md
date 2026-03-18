# Dashboard — Streamlit

Interactive data exploration dashboard built with Streamlit (Python).

**Recommended starting point** for this project — consistent with the Python analysis pipeline, low setup overhead, and accessible to partner organizations via a shareable URL.

---

## Setup

```bash
pip install streamlit boto3 pandas plotly python-dotenv
```

AWS credentials must be configured before running. See `../../database/README.md`.

## Usage

```bash
streamlit run app.py
```

Opens at `http://localhost:8501` in your browser.

## Features

- Filter by waterbody and sample type (Water / Sediment / Animal)
- Site map with sampling locations
- Microparticle concentration boxplots by waterbody
- FTIR polymer breakdown bar chart
- Downloadable filtered CSV

## Deployment

For a shareable public URL, deploy to **Streamlit Community Cloud** (free for public repos):

1. Push this repo to GitHub
2. Go to [share.streamlit.io](https://share.streamlit.io)
3. Connect your repo and point to `dashboard/streamlit/app.py`
4. Add AWS credentials as secrets in the Streamlit Cloud dashboard

## Notes

The app fetches data from DynamoDB on load and caches it for 5 minutes using `@st.cache_data`. For large tables, consider pre-exporting to CSV and loading statically to reduce AWS read costs.