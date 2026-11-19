// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/wcs_studio_web.ex",
    "../lib/wcs_studio_web/**/*.*ex",
  ],
  theme: {
    extend: {
      colors: {
        // Text aliases — see DESIGN.md 0.1. Brightened for contrast on
        // the saturated dark surfaces below.
        strong: "#ffffff",
        body: "#e4e9f7",
        muted: "#b4c0dc",
        subtle: "#8b9bc0",

        brand: {
          from: "#ff2d95", // vivid pink - canonical gradient start
          to: "#9d4dff", // vivid violet - canonical gradient end
          lightFrom: "#ff74c2", // hero text gradient start
          lightTo: "#c98cff", // hero text gradient end
          soft: "#ffa8de", // pink-300 - chip text (master hue)
          hoverFrom: "#e00078", // gradient hover start
          hoverTo: "#7d1fd4", // gradient hover end
          deepTo: "#5b0fa8", // deepest gradient hover
        },
        accent: {
          // Two-hue pairs, restored from master and saturated:
          // blue→cyan, green→emerald, yellow→orange, red→pink.
          info: "#2f6bff", // vivid blue
          infoTo: "#00d5ff", // vivid cyan
          infoHoverFrom: "#1f54e0",
          infoHoverTo: "#0098c9",
          infoLight: "#5ee7ff",
          infoLightTo: "#82b6ff",

          success: "#00e05a", // vivid green
          successTo: "#00b878", // vivid emerald
          successHoverFrom: "#00c44d",
          successHoverTo: "#009a68",
          successLight: "#5affc4",
          successLightTo: "#6bff91",

          warning: "#ffd400", // vivid yellow
          warningTo: "#ff7a00", // vivid orange (master video hue)
          warningHoverFrom: "#f5b800", // master yellow-500
          warningHoverTo: "#e85d00",
          warningLight: "#ffcf3d",
          warningLightTo: "#ff9a4d",
          amber: "#ff9e00", // master description-icon hue

          danger: "#ff3b4e", // vivid red
          dangerTo: "#ff4fa3", // vivid pink
          dangerHoverFrom: "#e01f35",
          dangerHoverTo: "#d10a63",
          dangerLight: "#ff7791",
          dangerLightTo: "#ff79bd",
        },
        hero: {
          "ambient-1": "#6a1fb5", // vivid purple wash
          "ambient-2": "#b31769", // vivid pink wash
        },
        surface: {
          base: "#140f2e", // deep indigo instead of neutral slate
          raised: "#211a40", // violet-tinted panel
          muted: "#352b57", // violet-tinted inset
        },
      },
      borderColor: {
        subtle: "#3a2f60",
        strong: "#51447f",
      },
      fontFamily: {
        sans: ["Inter", "sans-serif"],
      },
      fontSize: {
        display: ["3.5rem", { lineHeight: "1.05", letterSpacing: "-0.025em" }],
        "display-sm": ["3rem", { lineHeight: "1.1", letterSpacing: "-0.02em" }],
        lead: ["1.25rem", { lineHeight: "1.5" }],
        heading: ["1.875rem", { lineHeight: "1.2", letterSpacing: "-0.01em" }],
        "heading-sm": ["1.25rem", { lineHeight: "1.3" }],
        body: ["1rem", { lineHeight: "1.6" }],
        caption: ["0.875rem", { lineHeight: "1.5" }],
        button: ["0.875rem", { lineHeight: "1.25rem" }],
        pill: ["0.75rem", { lineHeight: "1rem" }],
      },
      spacing: {
        section: "5rem",
        "section-sm": "4rem",
      },
      borderRadius: {
        sm: "4px",
        md: "6px",
        lg: "8px",
        xl: "12px",
      },
      boxShadow: {
        // Master pattern-card depth hierarchy, expressed with brand-tinted hues.
        panel:
          "0 10px 15px -3px rgb(103 45 180 / 0.22), 0 4px 6px -4px rgb(255 45 149 / 0.12)",
        raised:
          "0 10px 15px -3px rgb(103 45 180 / 0.3), 0 4px 6px -4px rgb(255 45 149 / 0.15)",
        card: "0 20px 25px -5px rgb(60 15 110 / 0.45), 0 8px 10px -6px rgb(255 45 149 / 0.18)",
        lift: "0 25px 50px -12px rgb(60 15 110 / 0.6)",
        glow: "0 0 25px -5px rgb(255 45 149 / 0.7)",
      },
      keyframes: {
        slideUp: {
          "0%": { opacity: "0", transform: "translateY(40px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        fadeIn: {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
        "pulse-glow": {
          "0%": { boxShadow: "0 0 20px rgba(255, 45, 149, 0.55)" },
          "100%": { boxShadow: "0 0 30px rgba(157, 77, 255, 0.75)" },
        },
      },
      animation: {
        slideUp: "slideUp 0.8s ease-out forwards",
        fadeIn: "fadeIn 1s ease-out forwards",
        "pulse-glow": "pulse-glow 2s ease-in-out infinite alternate",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),

    // LiveView variants
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [
        ".phx-no-feedback&",
        ".phx-no-feedback &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ]),
    ),
  ],
};
