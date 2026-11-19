// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")

module.exports = {
    content: [
        "./js/**/*.js",
        "../lib/wcs_studio_web.ex",
        "../lib/wcs_studio_web/**/*.*ex"
    ],
    theme: {
        extend: {
            colors: {
                // Text aliases — see DESIGN.md 0.1
                strong: '#ffffff',
                body: '#cbd5e1',   // slate-300
                muted: '#94a3b8',  // slate-400
                subtle: '#64748b', // slate-500

                brand: {
                    from: '#ec4899',     // pink-500 - canonical gradient start
                    to: '#a855f7',       // purple-500 - canonical gradient end
                    lightFrom: '#f472b6', // pink-400 - hero text gradient
                    lightTo: '#c084fc',   // purple-400 - hero text gradient
                    hoverFrom: '#db2777', // pink-600 - gradient hover start
                    hoverTo: '#9333ea',   // purple-600 - gradient hover end
                    deepTo: '#7e22ce',    // purple-700 - deepest gradient hover
                },
                accent: {
                    info: '#a78bfa',    // lighter purple - links, info chips
                    success: '#10b981', // learned / attended
                    warning: '#fbbf24', // in progress
                    danger: '#f43f5e',  // rose - shares the brand's pink hue
                },
                hero: {
                    'ambient-1': '#4c1d95', // purple-900 - tokenized hero wash
                    'ambient-2': '#831843', // pink-900 - tokenized hero wash
                },
                surface: {
                    base: '#0f172a',   // slate-900
                    raised: '#1e293b', // slate-800
                    muted: '#334155',  // slate-700
                },
            },
            borderColor: {
                subtle: '#334155', // slate-700
                strong: '#475569', // slate-600
            },
            fontFamily: {
                sans: ['Inter', 'sans-serif'],
            },
            fontSize: {
                display: ['3.5rem', { lineHeight: '1.05', letterSpacing: '-0.025em' }],
                'display-sm': ['3rem', { lineHeight: '1.1', letterSpacing: '-0.02em' }],
                lead: ['1.25rem', { lineHeight: '1.5' }],
                heading: ['1.875rem', { lineHeight: '1.2', letterSpacing: '-0.01em' }],
                'heading-sm': ['1.25rem', { lineHeight: '1.3' }],
                body: ['1rem', { lineHeight: '1.6' }],
                caption: ['0.875rem', { lineHeight: '1.5' }],
                button: ['0.875rem', { lineHeight: '1.25rem' }],
                pill: ['0.75rem', { lineHeight: '1rem' }],
            },
            spacing: {
                section: '5rem',
                'section-sm': '4rem',
            },
            borderRadius: {
                sm: '4px',
                md: '6px',
                lg: '8px',
                xl: '12px',
            },
            boxShadow: {
                raised: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
                card: '0 25px 50px -12px rgb(0 0 0 / 0.25)',
                glow: '0 0 25px -5px rgb(236 72 153 / 0.5)',
            },
            keyframes: {
                slideUp: {
                    '0%': { opacity: '0', transform: 'translateY(40px)' },
                    '100%': { opacity: '1', transform: 'translateY(0)' }
                },
                fadeIn: {
                    '0%': { opacity: '0' },
                    '100%': { opacity: '1' }
                },
                'pulse-glow': {
                    '0%': { boxShadow: '0 0 20px rgba(236, 72, 153, 0.4)' },
                    '100%': { boxShadow: '0 0 30px rgba(168, 85, 247, 0.6)' }
                }
            },
            animation: {
                'slideUp': 'slideUp 0.8s ease-out forwards',
                'fadeIn': 'fadeIn 1s ease-out forwards',
                'pulse-glow': 'pulse-glow 2s ease-in-out infinite alternate',
            },
        },
    },
    plugins: [
        require("@tailwindcss/forms"),

        // LiveView variants
        plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
        plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
        plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
        plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"]))
    ]
}
