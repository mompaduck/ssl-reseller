// app/javascript/controllers/email_check_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "message", "checkButton"]
  
  emailChecked = false

  connect() {
    console.log("✅ email-check controller connected")
  }

  checkEmail(event) {
    event.preventDefault()
    const email = this.emailTarget.value

    if (!email) {
      this.showMessage("이메일을 입력하세요", "error")
      return
    }

    // 이메일 형식 체크
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      this.showMessage("올바른 이메일 형식이 아닙니다", "error")
      return
    }

    // 버튼 비활성화
    this.checkButtonTarget.disabled = true
    this.checkButtonTarget.textContent = "확인중..."

    fetch(`/users/check_email?email=${encodeURIComponent(email)}`)
      .then(response => {
        console.log("Response status:", response.status)
        return response.json()
      })
      .then(data => {
        console.log("Response data:", data)
        
        // exists 값으로 체크 (서버에서 exists: true/false 반환)
        if (data.exists === false) {
          this.emailChecked = true
          this.showMessage("✓ 사용 가능한 이메일입니다", "success")
          this.checkButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
          this.checkButtonTarget.textContent = "확인완료"
        } else {
          this.emailChecked = false
          this.showMessage("이미 사용 중인 이메일입니다", "error")
          this.checkButtonTarget.disabled = false
          this.checkButtonTarget.textContent = "중복확인"
        }
      })
      .catch(error => {
        console.error("Email check error:", error)
        this.showMessage("이메일 확인 중 오류가 발생했습니다", "error")
        this.checkButtonTarget.disabled = false
        this.checkButtonTarget.textContent = "중복확인"
      })
  }

  resetChecked() {
    this.emailChecked = false
    this.hideMessage()
    if (this.hasCheckButtonTarget) {
      this.checkButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      this.checkButtonTarget.disabled = false
      this.checkButtonTarget.textContent = "중복확인"
    }
  }

  validateBeforeSubmit(event) {
    if (!this.emailChecked) {
      event.preventDefault()
      event.stopPropagation()
      this.showMessage("⚠️ 이메일 중복확인을 해주세요", "error")
      return false
    }
    return true
  }

  showMessage(text, type) {
    this.messageTarget.textContent = text
    this.messageTarget.className = `text-sm mt-1 ${type === 'success' ? 'text-green-600' : 'text-red-600'}`
    this.messageTarget.classList.remove("hidden")
  }

  hideMessage() {
    if (this.hasMessageTarget) {
      this.messageTarget.classList.add("hidden")
    }
  }
}