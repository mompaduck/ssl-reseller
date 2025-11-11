// app/javascript/controllers/password_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "currentPassword", "currentPasswordLabel"]

  connect() {
    // 페이지 로드 시 (예: validation 실패 후)에도 상태를 확인
    this.toggleCurrentPassword()
  }

  toggleCurrentPassword() {
    const isPasswordPresent = this.passwordTarget.value.length > 0
    
    // 새 비밀번호가 입력되면, 현재 비밀번호 필드를 필수로 만듦
    this.currentPasswordTarget.required = isPasswordPresent

    // 시각적 표시 (라벨 옆에 빨간 별표)
    const asterisk = this.currentPasswordLabelTarget.querySelector('span.text-red-500')
    if (asterisk) {
      asterisk.classList.toggle('hidden', !isPasswordPresent)
    }
  }
}
