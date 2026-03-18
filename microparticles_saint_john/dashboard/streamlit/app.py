"""
app.py — Streamlit Dashboard
-----------------------------
Interactive dashboard for the microparticles_saint_john project.
Connects to AWS DynamoDB and displays microparticle data from the
Wolastoq/Saint John River watershed.

Features:
    - Site map with microparticle concentration overlay
    - Filter by waterbody, sample type, polymer type
    - Summary statistics table
    - FTIR confirmation breakdown
    - Downloadable filtered CSV

Usage:
    streamlit run app.py

Requirements:
    pip install streamlit boto3 pandas plotly

AWS credentials must be configured via environment variables or ~/.aws/credentials.
Do NOT hardcode credentials in this file.
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import sys
from pathlib import Path

# Add database directory to path for imports
sys.path.append(str(Path(__file__).parent.parent.parent / "database"))

from data_extraction import (
    get_all_sites,
    get_all_samples,
    get_all_ftir,
)
from joining_tables import join_all_samples, join_site_animal_ftir, join_site_water_ftir

# ---------------------------------------------------------------------------
# Page config
# ---------------------------------------------------------------------------

st.set_page_config(
    page_title="Microparticles — Wolastoq/Saint John Watershed",
    page_icon="🌊",
    layout="wide",
)

# ---------------------------------------------------------------------------
# Data loading (cached to avoid repeated DynamoDB calls)
# ---------------------------------------------------------------------------

@st.cache_data(ttl=300)
def load_sites():
    return get_all_sites()

@st.cache_data(ttl=300)
def load_all_samples():
    return join_all_samples()

@st.cache_data(ttl=300)
def load_ftir():
    return get_all_ftir()

# ---------------------------------------------------------------------------
# Sidebar filters
# ---------------------------------------------------------------------------

st.sidebar.title("Filters")

sites_df = load_sites()
samples_df = load_all_samples()
ftir_df = load_ftir()

# Waterbody filter
waterbodies = ["All"] + sorted(sites_df["waterbody"].dropna().unique().tolist()) if not sites_df.empty else ["All"]
selected_waterbody = st.sidebar.selectbox("Waterbody", waterbodies)

# Sample type filter
sample_types = ["All", "Water", "Sediment", "Animal"]
selected_type = st.sidebar.selectbox("Sample Type", sample_types)

# Apply filters
filtered = samples_df.copy() if not samples_df.empty else pd.DataFrame()

if not filtered.empty:
    if selected_waterbody != "All":
        filtered = filtered[filtered["waterbody"] == selected_waterbody]
    if selected_type != "All":
        filtered = filtered[filtered["sample_type"] == selected_type.lower()]

# ---------------------------------------------------------------------------
# Main layout
# ---------------------------------------------------------------------------

st.title("🌊 Microparticles in the Wolastoq / Saint John River Watershed")
st.markdown(
    "Visually identified microparticles in water, sediment, and animal samples "
    "collected by partner organizations across the watershed. "
    "A subset of samples were confirmed via micro-FTIR spectroscopy."
)

# --- Key metrics ---
col1, col2, col3, col4 = st.columns(4)

if not filtered.empty:
    col1.metric("Sites", filtered["site_id"].nunique() if "site_id" in filtered.columns else "—")
    col2.metric("Samples", len(filtered))
    col3.metric("Total Microparticles",
                int(filtered["microparticle_count"].sum()) if "microparticle_count" in filtered.columns else "—")
    col4.metric("FTIR Records", len(ftir_df) if not ftir_df.empty else 0)
else:
    for col in [col1, col2, col3, col4]:
        col.metric("—", "No data")

st.markdown("---")

# --- Map ---
st.subheader("Site Map")

if not sites_df.empty and "latitude" in sites_df.columns and "longitude" in sites_df.columns:
    map_df = sites_df.copy()
    if selected_waterbody != "All":
        map_df = map_df[map_df["waterbody"] == selected_waterbody]

    fig_map = px.scatter_mapbox(
        map_df,
        lat="latitude",
        lon="longitude",
        hover_name="site_id",
        hover_data=["waterbody", "partner_org", "habitat_type"],
        color="habitat_type",
        zoom=7,
        height=450,
        mapbox_style="open-street-map",
        title="Sampling Sites",
    )
    st.plotly_chart(fig_map, use_container_width=True)
else:
    st.info("Site location data not available.")

st.markdown("---")

# --- Concentration by waterbody ---
st.subheader("Microparticle Concentration by Waterbody")

if not filtered.empty and "concentration" in filtered.columns and "waterbody" in filtered.columns:
    fig_box = px.box(
        filtered,
        x="waterbody",
        y="concentration",
        color="sample_type",
        labels={"concentration": "Concentration (particles/unit)", "waterbody": "Waterbody"},
        height=400,
    )
    st.plotly_chart(fig_box, use_container_width=True)
else:
    st.info("Sample concentration data not available.")

# --- FTIR polymer breakdown ---
st.subheader("FTIR Polymer Composition")

if not ftir_df.empty and "polymer_type" in ftir_df.columns:
    polymer_counts = ftir_df["polymer_type"].value_counts().reset_index()
    polymer_counts.columns = ["Polymer Type", "Count"]
    fig_bar = px.bar(
        polymer_counts,
        x="Polymer Type",
        y="Count",
        color="Polymer Type",
        title="Polymer types identified by micro-FTIR",
        height=350,
    )
    st.plotly_chart(fig_bar, use_container_width=True)
else:
    st.info("FTIR data not available.")

st.markdown("---")

# --- Data table + download ---
st.subheader("Sample Data")

if not filtered.empty:
    display_cols = [c for c in [
        "sample_id", "sample_type", "site_id", "waterbody",
        "collection_date", "microparticle_count", "concentration", "partner_org"
    ] if c in filtered.columns]
    st.dataframe(filtered[display_cols], use_container_width=True)

    csv = filtered.to_csv(index=False).encode("utf-8")
    st.download_button(
        label="⬇ Download filtered data as CSV",
        data=csv,
        file_name="microparticles_filtered.csv",
        mime="text/csv",
    )
else:
    st.info("No data to display with current filters.")

# ---------------------------------------------------------------------------
# Footer
# ---------------------------------------------------------------------------

st.markdown("---")
st.caption(
    "Data contributed by: UNB Saint John · Huntsman Marine Science Centre · "
    "Mount Allison University · Coastal Action · ACAP Saint John · "
    "Passamaquoddy Recognition Group · Dalhousie University"
)
