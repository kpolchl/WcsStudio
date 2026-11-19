// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
    content: [
        "./js/**/*.js",
        "../lib/wcs_studio_web.ex",
        "../lib/wcs_studio_web/**/*.*ex"
    ],
    theme: {
        extend: {
            colors: {
                'accent-start': '#ec4899', // pink-500
                'accent-end': '#a855f7',   // purple-500
                brand: {
                    from: '#ec4899', // pink-500 - canonical gradient start
                    to: '#a855f7',   // purple-500 - canonical gradient end
                    soft: '#fdf2f8', // pink-50 - subtle brand surface
                },
                surface: {
                    base: '#0f172a',   // slate-900
                    raised: '#1e293b', // slate-800
                    muted: '#334155',  // slate-700
                },
            },
            fontFamily: {
                sans: ['Inter', 'sans-serif'],
            },
            borderRadius: {
                sm: '8px',
                md: '12px',
                lg: '16px',
                xl: '24px',
            },
            boxShadow: {
                raised: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
                card: '0 25px 50px -12px rgb(0 0 0 / 0.25)',
                glow: '0 0 25px -5px rgb(236 72 153 / 0.5)',
                focus: '0 0 0 3px rgb(236 72 153 / 0.35)',
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
        plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

        // Heroicons integration
        plugin(function ({ matchComponents, theme }) {
            let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
            let values = {}
            let icons = [
                ["", "/24/outline"],
                ["-solid", "/24/solid"],
                ["-mini", "/20/solid"],
                ["-micro", "/16/solid"]
            ]

            icons.forEach(([suffix, dir]) => {
                fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
                    let name = path.basename(file, ".svg") + suffix
                    values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
                })
            })

            matchComponents({
                "hero": ({ name, fullPath }) => {
                    let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
                    let size = theme("spacing.6")
                    if (name.endsWith("-mini")) {
                        size = theme("spacing.5")
                    } else if (name.endsWith("-micro")) {
                        size = theme("spacing.4")
                    }
                    return {
                        [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
                        "-webkit-mask": `var(--hero-${name})`,
                        "mask": `var(--hero-${name})`,
                        "mask-repeat": "no-repeat",
                        "background-color": "currentColor",
                        "vertical-align": "middle",
                        "display": "inline-block",
                        "width": size,
                        "height": size
                    }
                }
            }, { values })
        })
    ]
}
