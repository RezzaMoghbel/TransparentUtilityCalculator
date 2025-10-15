// IMPORTANT: Chart.js must be loaded globally in your layout before this module is imported.

export function renderCurrencyLineChart(
  canvasId,
  labels,
  data,
  seriesName,
  currency
) {
  const el = document.getElementById(canvasId);
  if (!el) return;
  const ctx = el.getContext("2d");

  if (!window._charts) window._charts = {};
  if (window._charts[canvasId]) window._charts[canvasId].destroy();

  window._charts[canvasId] = new Chart(ctx, {
    type: "line",
    data: {
      labels,
      datasets: [{ label: seriesName, data, tension: 0.2, fill: false }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        tooltip: {
          callbacks: {
            label: (c) =>
              `${c.dataset.label}: ${currency}${Number(c.parsed.y).toFixed(2)}`,
          },
        },
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: { callback: (v) => currency + Number(v).toFixed(2) },
        },
      },
    },
  });
}

export function renderGroupedBarChart(
  canvasId,
  labels,
  ddData,
  linkedData,
  statusData,
  currency
) {
  const el = document.getElementById(canvasId);
  if (!el) return;
  const ctx = el.getContext("2d");

  if (!window._charts) window._charts = {};
  if (window._charts[canvasId]) window._charts[canvasId].destroy();

  // Map status to colors for DD bars
  const ddColors = statusData.map((status) => {
    if (status === "Exact") return "rgba(40, 167, 69, 0.8)"; // Green
    if (status === "Overpaid") return "rgba(255, 193, 7, 0.8)"; // Yellow
    if (status === "Underpaid") return "rgba(220, 53, 69, 0.8)"; // Red
    return "rgba(108, 117, 125, 0.8)"; // Gray
  });

  window._charts[canvasId] = new Chart(ctx, {
    type: "bar",
    data: {
      labels,
      datasets: [
        {
          label: "Linked Utility Readings",
          data: linkedData,
          backgroundColor: "rgba(13, 110, 253, 0.8)",
          borderColor: "rgba(13, 110, 253, 1)",
          borderWidth: 1,
        },
        {
          label: "Direct Debit Payments",
          data: ddData,
          backgroundColor: ddColors,
          borderColor: ddColors.map((c) => c.replace("0.8", "1")),
          borderWidth: 1,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: true, position: "top" },
        tooltip: {
          callbacks: {
            label: (c) =>
              `${c.dataset.label}: ${currency}${Number(c.parsed.y).toFixed(2)}`,
          },
        },
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: { callback: (v) => currency + Number(v).toFixed(2) },
        },
      },
    },
  });
}
