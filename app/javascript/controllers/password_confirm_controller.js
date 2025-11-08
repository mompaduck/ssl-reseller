// app/javascript/controllers/password_confirm_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "passwordConfirmation", "message"]
  
  passwordsMatch = false

  connect() {
    console.log("✅ password-confirm controller connected")
  }

  checkMatch() {
    const password = this.passwordTarget.value
    const confirmation = this.passwordConfirmationTarget.value

    // 둘 다 입력된 경우에만 체크
    if (password && confirmation) {
      if (password === confirmation) {
        this.passwordsMatch = true
        this.hideMessage()
      } else {
        this.passwordsMatch = false
        this.showMessage()
      }
    } else {
      // 입력 중일 때는 메시지 숨김
      this.hideMessage()
    }
  }

  validateBeforeSubmit(event) {
    const password = this.passwordTarget.value
    const confirmation = this.passwordConfirmationTarget.value

    if (!password || !confirmation) {
      event.preventDefault()
      alert("비밀번호를 입력해주세요")
      return
    }

    if (password !== confirmation) {
      event.preventDefault()
      this.showMessage()
      alert("비밀번호가 일치하지 않습니다")
    }
  }

  showMessage() {
    this.messageTarget.classList.remove("hidden")
  }

  hideMessage() {
    this.messageTarget.classList.add("hidden")
  }
}