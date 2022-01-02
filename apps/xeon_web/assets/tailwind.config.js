const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  mode: 'jit',
  purge: ['src/**/*.{ts,tsx}', '../lib/**/*.*ex'],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        brand: colors.blue,
      },
    },
    container: {
      center: true,
      padding: {
        DEFAULT: '1rem',
      },
    },
    extend: {
      boxShadow: {
        input: 'inset 0 1px 4px 1px rgba(0, 0, 0, 0.04)',
      },
      colors: {
        brand: {
          50: '#fcfbf9',
          100: '#fbf0e3',
          200: '#f6d3c5',
          300: '#eaa996',
          400: '#e27968',
          500: '#d15645',
          600: '#b73c2e',
          700: '#8f2d23',
          800: '#651f19',
          900: '#3f130f',
        },
        accent: {
          50: '#fbfaf6',
          100: '#f8f0d1',
          200: '#efdca1',
          300: '#d9b76c',
          400: '#bc8c40',
          500: '#9d6c23',
          600: '#805217',
          700: '#613d13',
          800: '#422a10',
          900: '#2b1a0b',
        },
      },
      zIndex: {
        '-10': '-10',
      },
    },
    fontFamily: {
      sans: ['Lexend', ...defaultTheme.fontFamily.sans],
      serif: ['Oswald', ...defaultTheme.fontFamily.serif],
    },
  },
  variants: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/aspect-ratio'),
    // ...
  ],
}
