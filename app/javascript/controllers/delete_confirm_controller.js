// app/javascript/controllers/delete_confirm_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "submitButton"]
  
  connect() {
    console.log("✅ delete-confirm controller connected")
    this.updateButtonState()
  }

  checkPassword() {
    this.updateButtonState()
  }

  updateButtonState() {
    const password = this.passwordTarget.value.trim()
    
    if (password.length > 0) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      this.submitButtonTarget.classList.add("cursor-pointer", "hover:bg-red-700")
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.submitButtonTarget.classList.remove("cursor-pointer", "hover:bg-red-700")
    }
  }

  validateBeforeSubmit(event) {
    const password = this.passwordTarget.value.trim()

    if (!password) {
      event.preventDefault()
      alert("계정 삭제를 위해 현재 비밀번호를 입력해주세요")
      return
    }

    // 최종 확인 메시지
    if (!confirm("정말로 계정을 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없으며, 모든 데이터가 영구적으로 삭제됩니다.")) {
      event.preventDefault()
    }
  }
}