import { Application } from "@hotwired/stimulus"


const application = Application.start()
window.Stimulus = application  // 필요시 디버그용

export { application }

// Stimulus 앱을 한 번 시작하고, 모든 컨트롤러 등록은 index.js에 집중시켜 관리