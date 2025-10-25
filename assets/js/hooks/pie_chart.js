import { Chart } from 'chart.js/auto';

const PieChart = {
    mounted() {
        this.initChart();
    },

    updated() {
        this.updateChart();
    },

    destroyed() {
        this.destroyChart();
    },

    initChart() {
        const canvas = this.el;
        const labels = canvas.dataset.labels.split(',').filter(l => l);
        const values = canvas.dataset.values.split(',').map(Number);

        // Initialize cache and dimensions
        this.gradientCache = new Map();
        this.chartWidth = null;
        this.chartHeight = null;

        // Generate base colors matching your app style
        const colors = this.generateBaseColors(values.length);

        this.chart = new Chart(canvas, {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{
                    data: values,
                    backgroundColor: (context) => this.createSegmentGradient(context, colors),
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 15,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1);
                                return `${label}: ${value} (${percentage}%)`;
                            }
                        }
                    }
                },
                // Add interaction effects
                interaction: {
                    mode: 'nearest',
                    intersect: true
                }
            }
        });
    },

    updateChart() {
        if (!this.chart) {
            this.initChart();
            return;
        }

        const canvas = this.el;
        const labels = canvas.dataset.labels.split(',').filter(l => l);
        const values = canvas.dataset.values.split(',').map(Number);

        this.chart.data.labels = labels;
        this.chart.data.datasets[0].data = values;

        // Clear cache on update to regenerate gradients
        this.gradientCache.clear();
        this.chartWidth = null;
        this.chartHeight = null;

        this.chart.update();
    },

    destroyChart() {
        if (this.chart) {
            this.chart.destroy();
            this.chart = null;
        }
        if (this.gradientCache) {
            this.gradientCache.clear();
            this.gradientCache = null;
        }
    },

    createSegmentGradient(context, colors) {
        const chart = context.chart;
        const chartArea = chart.chartArea;

        if (!chartArea) {
            // This case happens on initial chart load
            return colors[context.dataIndex];
        }

        // Check if chart dimensions changed
        const currentWidth = chartArea.right - chartArea.left;
        const currentHeight = chartArea.bottom - chartArea.top;
        if (this.chartWidth !== currentWidth || this.chartHeight !== currentHeight) {
            this.gradientCache.clear();
            this.chartWidth = currentWidth;
            this.chartHeight = currentHeight;
        }

        const baseColor = colors[context.dataIndex];
        if (!baseColor) {
            return '#cccccc'; // fallback color
        }

        // Create cache key
        const cacheKey = `${baseColor}-${context.dataIndex}-${context.active ? 'active' : 'normal'}`;

        let gradient = this.gradientCache.get(cacheKey);
        if (!gradient) {
            // Adjust colors based on active state
            let startColor, midColor, endColor;

            if (context.active) {
                // Brighter colors when segment is hovered
                startColor = this.lightenColor(baseColor, 30);
                midColor = this.lightenColor(baseColor, 15);
                endColor = baseColor;
            } else {
                // Normal gradient
                startColor = this.lightenColor(baseColor, 20);
                midColor = this.darkenColor(baseColor, 10);
                endColor = this.darkenColor(baseColor, 20);
            }

            // Create radial gradient
            const centerX = (chartArea.left + chartArea.right) / 2;
            const centerY = (chartArea.top + chartArea.bottom) / 2;
            const radius = Math.min(
                (chartArea.right - chartArea.left) / 2,
                (chartArea.bottom - chartArea.top) / 2
            );

            const ctx = chart.ctx;
            gradient = ctx.createRadialGradient(
                centerX, centerY, 0,
                centerX, centerY, radius
            );

            gradient.addColorStop(0, startColor);
            gradient.addColorStop(0.7, midColor);
            gradient.addColorStop(1, endColor);

            this.gradientCache.set(cacheKey, gradient);
        }

        return gradient;
    },

    generateBaseColors(count) {
        // Updated color palette to match your app's gradient style
        const appColors = {
            // Purple to Pink gradient (from your badges)
            purplePink: 'rgb(168, 85, 247)',
            purple: 'rgb(147, 51, 234)',
            pink: 'rgb(236, 72, 153)',

            // Green to Emerald gradient (from your badges)
            green: 'rgb(34, 197, 94)',
            emerald: 'rgb(16, 185, 129)',
            teal: 'rgb(20, 184, 166)',

            // Blue to Cyan gradient (from your buttons)
            blue: 'rgb(59, 130, 246)',
            cyan: 'rgb(6, 182, 212)',
            lightBlue: 'rgb(14, 165, 233)',

            // Red to Orange gradient (from your video section)
            red: 'rgb(239, 68, 68)',
            orange: 'rgb(249, 115, 22)',
            amber: 'rgb(245, 158, 11)',

            // Additional colors that match your design
            indigo: 'rgb(99, 102, 241)',
            violet: 'rgb(139, 92, 246)',
            fuchsia: 'rgb(217, 70, 239)',
            appMedium: 'rgb(148, 163, 184)',   // slate-400
        };

        // Smooth sequence for pie charts
        const colorPalette = [
            appColors.purplePink,
            appColors.purple,
            appColors.violet,
            appColors.fuchsia,
            appColors.pink,
            appColors.red,
            appColors.orange,
            appColors.amber,
            appColors.green,
            appColors.emerald,
            appColors.teal,
            appColors.lightBlue,
            appColors.blue,
            appColors.cyan,
            appColors.indigo,
            appColors.appMedium
        ];

        const colors = [];
        for (let i = 0; i < count; i++) {
            if (i < colorPalette.length) {
                colors.push(colorPalette[i]);
            } else {
                // Generate additional colors using HSL for smooth distribution
                const hue = (i * 137.5) % 360; // golden angle for even spacing
                colors.push(`hsl(${hue}, 75%, 55%)`);
            }
        }

        return colors;
    },

    lightenColor(color, percent) {
        // Handle both RGB and HSL colors
        if (color.startsWith('hsl')) {
            return this.adjustHSLColor(color, percent, percent, 0);
        } else {
            return this.adjustRGBColor(color, percent);
        }
    },

    darkenColor(color, percent) {
        // Handle both RGB and HSL colors
        if (color.startsWith('hsl')) {
            return this.adjustHSLColor(color, -percent, -percent, 0);
        } else {
            return this.adjustRGBColor(color, -percent);
        }
    },

    adjustRGBColor(color, percent) {
        // Parse RGB color
        const match = color.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
        if (!match) return color;

        const r = parseInt(match[1]);
        const g = parseInt(match[2]);
        const b = parseInt(match[3]);

        const amount = Math.round(2.55 * percent);

        const newR = Math.max(0, Math.min(255, r + amount));
        const newG = Math.max(0, Math.min(255, g + amount));
        const newB = Math.max(0, Math.min(255, b + amount));

        return `rgb(${newR}, ${newG}, ${newB})`;
    },

    adjustHSLColor(color, hPercent, sPercent, lPercent) {
        // Parse HSL color
        const match = color.match(/hsl\((\d+),\s*(\d+)%,\s*(\d+)%\)/);
        if (!match) return color;

        let h = parseInt(match[1]);
        let s = parseInt(match[2]);
        let l = parseInt(match[3]);

        // Adjust values
        h = (h + hPercent) % 360;
        s = Math.max(0, Math.min(100, s + sPercent));
        l = Math.max(0, Math.min(100, l + lPercent));

        return `hsl(${h}, ${s}%, ${l}%)`;
    }
};

export default PieChart;