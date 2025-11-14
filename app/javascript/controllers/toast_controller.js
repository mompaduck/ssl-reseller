import { Controller } from "@hotwired/stimulus"

// 자동으로 사라지는 토스트 메시지를 위한 컨트롤러
export default class extends Controller {
  connect() {
    // 5초 후에 자동으로 사라지도록 타이머 설정
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    // 컨트롤러가 DOM에서 제거될 때 타이머도 함께 정리
    clearTimeout(this.timeout)
  }

  // 토스트를 부드럽게 사라지게 하는 액션
  dismiss() {
    // 1. fade-out-breathe 클래스를 추가하여 애니메이션 시작
    this.element.classList.add("fade-out-breathe")

    // 2. 애니메이션이 끝난 후(500ms) DOM에서 요소를 완전히 제거
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}