/**
 * App.jsx — React Dashboard Framework
 * -------------------------------------
 * Interactive dashboard for the microparticles_saint_john project.
 * Fetches data from a backend API (see notes below) and displays
 * microparticle data from the Wolastoq/Saint John River watershed.
 *
 * NOTE ON DYNAMODB ACCESS FROM REACT:
 * DynamoDB cannot be called directly from a browser frontend without
 * exposing AWS credentials. This React app expects a lightweight backend
 * API (e.g., AWS Lambda + API Gateway, or a FastAPI/Flask server) that
 * wraps the boto3 queries in database/data_extraction.py.
 * The API_BASE_URL below should point to that backend.
 *
 * For rapid prototyping without a backend, use the Streamlit app instead
 * (dashboard/streamlit/app.py).
 *
 * Setup:
 *   npm create vite@latest microparticles-dashboard -- --template react
 *   cd microparticles-dashboard
 *   npm install
 *   npm install recharts leaflet react-leaflet
 *   Replace src/App.jsx with this file.
 *   npm run dev
 */

import { useState, useEffect } from "react";
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  Legend, ResponsiveContainer, BoxPlot
} from "recharts";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const API_BASE_URL = "YOUR_API_BASE_URL"; // e.g. "https://your-api-id.execute-api.ca-central-1.amazonaws.com/prod"

// ---------------------------------------------------------------------------
// Data fetching helpers
// ---------------------------------------------------------------------------

async function fetchJSON(endpoint) {
  const response = await fetch(`${API_BASE_URL}${endpoint}`);
  if (!response.ok) throw new Error(`API error: ${response.status} ${endpoint}`);
  return response.json();
}

// ---------------------------------------------------------------------------
// Components
// ---------------------------------------------------------------------------

function MetricCard({ label, value }) {
  return (
    <div style={styles.metricCard}>
      <div style={styles.metricValue}>{value ?? "—"}</div>
      <div style={styles.metricLabel}>{label}</div>
    </div>
  );
}

function SampleTable({ samples }) {
  if (!samples || samples.length === 0) return <p>No samples to display.</p>;

  const cols = ["sample_id", "sample_type", "waterbody", "collection_date",
                "microparticle_count", "concentration"];

  const downloadCSV = () => {
    const header = cols.join(",");
    const rows = samples.map(row => cols.map(c => row[c] ?? "").join(","));
    const csv = [header, ...rows].join("\n");
    const blob = new Blob([csv], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "microparticles_filtered.csv";
    a.click();
  };

  return (
    <div>
      <button onClick={downloadCSV} style={styles.button}>⬇ Download CSV</button>
      <div style={{ overflowX: "auto" }}>
        <table style={styles.table}>
          <thead>
            <tr>{cols.map(c => <th key={c} style={styles.th}>{c}</th>)}</tr>
          </thead>
          <tbody>
            {samples.slice(0, 50).map((row, i) => (
              <tr key={i}>
                {cols.map(c => <td key={c} style={styles.td}>{row[c] ?? ""}</td>)}
              </tr>
            ))}
          </tbody>
        </table>
        {samples.length > 50 && (
          <p style={{ color: "#888" }}>Showing first 50 of {samples.length} rows. Download CSV for full dataset.</p>
        )}
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Main App
// ---------------------------------------------------------------------------

export default function App() {
  const [sites, setSites] = useState([]);
  const [samples, setSamples] = useState([]);
  const [ftir, setFtir] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Filters
  const [selectedWaterbody, setSelectedWaterbody] = useState("All");
  const [selectedType, setSelectedType] = useState("All");

  useEffect(() => {
    async function loadData() {
      try {
        const [sitesData, samplesData, ftirData] = await Promise.all([
          fetchJSON("/sites"),
          fetchJSON("/samples"),
          fetchJSON("/ftir"),
        ]);
        setSites(sitesData);
        setSamples(samplesData);
        setFtir(ftirData);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);

  if (loading) return <div style={styles.loading}>Loading data from DynamoDB...</div>;
  if (error) return <div style={styles.error}>Error: {error}</div>;

  // Apply filters
  const filtered = samples
    .filter(s => selectedWaterbody === "All" || s.waterbody === selectedWaterbody)
    .filter(s => selectedType === "All" || s.sample_type === selectedType.toLowerCase());

  const waterbodies = ["All", ...new Set(sites.map(s => s.waterbody).filter(Boolean))];

  // FTIR polymer counts for bar chart
  const polymerCounts = ftir.reduce((acc, r) => {
    if (r.polymer_type) acc[r.polymer_type] = (acc[r.polymer_type] || 0) + 1;
    return acc;
  }, {});
  const polymerData = Object.entries(polymerCounts)
    .map(([name, count]) => ({ name, count }))
    .sort((a, b) => b.count - a.count);

  return (
    <div style={styles.app}>
      <header style={styles.header}>
        <h1 style={styles.title}>🌊 Microparticles — Wolastoq / Saint John River Watershed</h1>
        <p style={styles.subtitle}>
          Visually identified microparticles in water, sediment, and animal samples
          from partner organizations across the watershed.
        </p>
      </header>

      {/* Filters */}
      <div style={styles.filterBar}>
        <label style={styles.filterLabel}>Waterbody:&nbsp;
          <select value={selectedWaterbody} onChange={e => setSelectedWaterbody(e.target.value)}>
            {waterbodies.map(w => <option key={w}>{w}</option>)}
          </select>
        </label>
        <label style={styles.filterLabel}>Sample Type:&nbsp;
          <select value={selectedType} onChange={e => setSelectedType(e.target.value)}>
            {["All", "Water", "Sediment", "Animal"].map(t => <option key={t}>{t}</option>)}
          </select>
        </label>
      </div>

      {/* Metrics */}
      <div style={styles.metricRow}>
        <MetricCard label="Sites" value={new Set(filtered.map(s => s.site_id)).size} />
        <MetricCard label="Samples" value={filtered.length} />
        <MetricCard label="Total Microparticles"
          value={filtered.reduce((sum, s) => sum + (Number(s.microparticle_count) || 0), 0)} />
        <MetricCard label="FTIR Records" value={ftir.length} />
      </div>

      {/* Polymer chart */}
      <section style={styles.section}>
        <h2>FTIR Polymer Composition</h2>
        {polymerData.length > 0 ? (
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={polymerData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="count" fill="#2196F3" name="Count" />
            </BarChart>
          </ResponsiveContainer>
        ) : <p>No FTIR data available.</p>}
      </section>

      {/* Sample table */}
      <section style={styles.section}>
        <h2>Sample Data</h2>
        <SampleTable samples={filtered} />
      </section>

      <footer style={styles.footer}>
        Data contributed by: UNB Saint John · Huntsman Marine Science Centre ·
        Mount Allison University · Coastal Action · ACAP Saint John ·
        Passamaquoddy Recognition Group · Dalhousie University
      </footer>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Styles
// ---------------------------------------------------------------------------

const styles = {
  app: { fontFamily: "system-ui, sans-serif", maxWidth: 1100, margin: "0 auto", padding: "0 1.5rem" },
  header: { borderBottom: "2px solid #e0e0e0", paddingBottom: "1rem", marginBottom: "1.5rem" },
  title: { fontSize: "1.6rem", marginBottom: "0.3rem" },
  subtitle: { color: "#555", margin: 0 },
  filterBar: { display: "flex", gap: "2rem", marginBottom: "1.5rem" },
  filterLabel: { fontSize: "0.95rem" },
  metricRow: { display: "flex", gap: "1rem", marginBottom: "2rem", flexWrap: "wrap" },
  metricCard: { background: "#f5f5f5", borderRadius: 8, padding: "1rem 1.5rem", flex: "1 1 120px", textAlign: "center" },
  metricValue: { fontSize: "1.8rem", fontWeight: 700, color: "#1565C0" },
  metricLabel: { fontSize: "0.85rem", color: "#666", marginTop: "0.25rem" },
  section: { marginBottom: "2.5rem" },
  table: { width: "100%", borderCollapse: "collapse", fontSize: "0.88rem" },
  th: { background: "#e3f2fd", padding: "0.5rem 0.75rem", textAlign: "left", borderBottom: "1px solid #ccc" },
  td: { padding: "0.4rem 0.75rem", borderBottom: "1px solid #eee" },
  button: { marginBottom: "0.75rem", padding: "0.4rem 1rem", cursor: "pointer", background: "#1565C0", color: "#fff", border: "none", borderRadius: 4 },
  loading: { padding: "3rem", textAlign: "center", color: "#555" },
  error: { padding: "3rem", textAlign: "center", color: "#c62828" },
  footer: { borderTop: "1px solid #e0e0e0", padding: "1rem 0", color: "#888", fontSize: "0.8rem", marginTop: "2rem" },
};
