// tailwind.config.js
module.exports = {
  content: [
    "./app/views/**/*.{erb,html,html.erb}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.{js,ts,jsx,tsx}",
    "./app/assets/stylesheets/**/*.css"
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};