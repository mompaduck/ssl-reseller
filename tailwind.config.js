// tailwind.config.js
module.exports = {
  darkMode: 'class', // 또는 'media'
  content: [
    './app/views/**/*.{erb,haml,html,slim}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {},
  },
   plugins: [
    require('@tailwindcss/forms'),
  ],
}