const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require("../app/javascript/tailwindColors");

module.exports = {
  content: [
    './public/*.html',
    './app/models/**/*.rb',
    './app/helpers/**/*.rb',
    './app/presenters/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    colors,
    boxShadow: {
      none: "0 0 #0000",
      inner: "inset 0 2px 4px 0 rgb(0 0 0 / 0.05)",
      xs: "0px 1px 2px 0px rgba(11, 11, 11, 0.05)",
      sm: "0px 1px 2px 0px rgba(11, 11, 11, 0.06), 0px 1px 3px 0px rgba(11, 11, 11, 0.10)",
      md: "0px 2px 4px -2px rgba(11, 11, 11, 0.06), 0px 4px 8px -2px rgba(11, 11, 11, 0.10)",
      lg: "0px 4px 6px -2px rgba(11, 11, 11, 0.03), 0px 12px 16px -4px rgba(11, 11, 11, 0.08)",
      xl: "0px 8px 8px -4px rgba(11, 11, 11, 0.03), 0px 20px 24px -4px rgba(11, 11, 11, 0.08)",
      soft: "0 0 0 10px rgba(0, 0, 0, 0.02)",
      "2xl": "0px 24px 48px -12px rgba(11, 11, 11, 0.12)",
      "3xl": "0px 32px 64px -12px rgba(11, 11, 11, 0.14)",
      'btn-dark-inset-1': 'inset 0 1px 1px 0 rgba(255, 255, 255, 0.3)',
      'btn-dark-inset-2': 'inset 0 0 1px 0 #000000',
      'btn-dark-inset-3': 'inset 0 9px 14px -5px rgba(255, 255, 255, 0.3)',
      'btn-plain-inset-1': 'inset 0 0 0 1px rgba(0, 0, 0, 0.1)',
      'btn-plain-inset-2': 'inset 0 -6px 6px -5px rgba(30, 30, 30, 0.08)',
    },
    borderRadius: {
      none: "0",
      full: "9999px",
      xs: "2px",
      sm: "4px",
      md: "8px",
      DEFAULT: "8px",
      lg: "10px",
      xl: "12px",
      "2xl": "16px",
      "3xl": "24px",
    },
    extend: {
      fontFamily: {
        sans: ["Geist", ...defaultTheme.fontFamily.sans],
        mono: ["Geist Mono", ...defaultTheme.fontFamily.mono],
      },
      fontWeight: {
        medium: "450",
      },
      colors: {
        "color-1": "hsl(var(--color-1))",
        "color-2": "hsl(var(--color-2))",
        "color-3": "hsl(var(--color-3))",
        "color-4": "hsl(var(--color-4))",
        "color-5": "hsl(var(--color-5))",
      },
      animation: {
        rainbow: "rainbow var(--speed, 2s) infinite linear",
      },
      keyframes: {
        rainbow: {
          "0%": { "background-position": "0%" },
          "100%": { "background-position": "200%" },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
