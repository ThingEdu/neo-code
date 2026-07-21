// Neo Play design tokens — Tailwind theme extension snippet
// Merge this into your project's tailwind.config.js under `theme.extend`

module.exports = {
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#02D962',
          on: '#FFFFFF',
          container: '#C6F7D8',
          onContainer: '#00210F',
        },
        secondary: {
          DEFAULT: '#2E77E7',
          on: '#FFFFFF',
          container: '#D6E7FF',
          onContainer: '#001C3B',
        },
        tertiary: {
          DEFAULT: '#FE2151',
          on: '#FFFFFF',
        },
        error: {
          DEFAULT: '#B3261E',
          on: '#FFFFFF',
        },
        surface: {
          DEFAULT: '#FFFFFF',
          on: '#1A1C1E',
          variant: '#E1E2E8',
        },
        outline: '#74777F',
      },
      spacing: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '32px',
        xxl: '48px',
      },
      borderRadius: {
        none: '0px',
        xs: '4px',
        sm: '8px',
        md: '12px',
        lg: '16px',
        xl: '28px',
        full: '9999px',
      },
      boxShadow: {
        'elevation-1': '0px 1px 2px rgba(0,0,0,0.08)',
        'elevation-2': '0px 1px 3px rgba(0,0,0,0.12)',
        'elevation-3': '0px 4px 8px rgba(0,0,0,0.14)',
        'elevation-4': '0px 6px 10px rgba(0,0,0,0.16)',
        'elevation-5': '0px 8px 12px rgba(0,0,0,0.18)',
      },
      fontFamily: {
        base: ['Roboto', '-apple-system', 'Segoe UI', 'Arial', 'sans-serif'],
      },
    },
  },
};
