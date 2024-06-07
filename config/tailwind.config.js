const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require("../app/javascript/tailwindColors");

module.exports = {
  content: [
    './public/*.html',
    './app/models/**/*.rb',
    './app/helpers/**/*.rb',
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
      "2xl": "0px 24px 48px -12px rgba(11, 11, 11, 0.12)",
      "3xl": "0px 32px 64px -12px rgba(11, 11, 11, 0.14)",
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
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
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
