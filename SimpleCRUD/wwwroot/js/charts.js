// IMPORTANT: Chart.js must be loaded globally in your layout before this module is imported.

export function renderCurrencyLineChart(canvasId, labels, data, seriesName, currency) {
    const el = document.getElementById(canvasId);
    if (!el) return;
    const ctx = el.getContext('2d');

    if (!window._charts) window._charts = {};
    if (window._charts[canvasId]) window._charts[canvasId].destroy();

    window._charts[canvasId] = new Chart(ctx, {
        type: 'line',
        data: {
            labels,
            datasets: [{ label: seriesName, data, tension: 0.2, fill: false }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                tooltip: {
                    callbacks: {
                        label: (c) => `${c.dataset.label}: ${currency}${Number(c.parsed.y).toFixed(2)}`
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { callback: (v) => currency + Number(v).toFixed(2) }
                }
            }
        }
    });
}
