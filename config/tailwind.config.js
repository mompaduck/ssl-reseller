// tailwind.config.js
module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/javascript/**/*.{js,ts,jsx,tsx}',

    // 이 라인을 추가하거나, 이미 있다면 확인합니다.
    './app/assets/stylesheets/**/*.css', 
  ],
  // ...
}