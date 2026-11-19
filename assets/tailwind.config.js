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
            fontFamily: {
                sans: ['Lato', 'ui-sans-serif', 'system-ui', 'sans-serif'],
                display: ['"Josefin Sans"', 'ui-sans-serif', 'system-ui', 'sans-serif'],
            },
            colors: {
                'accent-start': '#ec4899', // pink-500
                'accent-end': '#a855f7',   // purple-500
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
                    '100%': { boxShadow: '0 0 30px rgba(192, 38, 211, 0.6)' }
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
