// app/javascript/controllers/email_check_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "message", "checkButton"]
  
  emailChecked = false
  lastCheckedEmail = ""

  connect() {
    console.log("✅ email-check controller connected")
  }

  checkEmail(event) {
    event.preventDefault()
    
    if (!this.hasEmailTarget) {
      console.error("Email target not found")
      return
    }

    const email = this.emailTarget.value.trim()

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
    if (this.hasCheckButtonTarget) {
      this.checkButtonTarget.disabled = true
      this.checkButtonTarget.textContent = "확인중..."
    }

    console.log("Checking email:", email)

    fetch(`/users/check_email?email=${encodeURIComponent(email)}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
      .then(response => {
        console.log("Response status:", response.status)
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }
        
        return response.json()
      })
      .then(data => {
        console.log("Response data:", data)
        
        // exists 값으로 체크 (서버에서 exists: true/false 반환)
        if (data.exists === false) {
          this.emailChecked = true
          this.lastCheckedEmail = email
          this.showMessage("✓ 사용 가능한 이메일입니다", "success")
          
          if (this.hasCheckButtonTarget) {
            this.checkButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
            this.checkButtonTarget.textContent = "확인완료"
          }
        } else {
          this.emailChecked = false
          this.lastCheckedEmail = ""
          this.showMessage("이미 사용 중인 이메일입니다", "error")
          
          if (this.hasCheckButtonTarget) {
            this.checkButtonTarget.disabled = false
            this.checkButtonTarget.textContent = "중복확인"
          }
        }
      })
      .catch(error => {
        console.error("Email check error:", error)
        this.emailChecked = false
        this.showMessage("이메일 확인 중 오류가 발생했습니다", "error")
        
        if (this.hasCheckButtonTarget) {
          this.checkButtonTarget.disabled = false
          this.checkButtonTarget.textContent = "중복확인"
        }
      })
  }

  resetChecked() {
    const currentEmail = this.hasEmailTarget ? this.emailTarget.value.trim() : ""
    
    // 이메일이 변경된 경우에만 체크 상태 리셋
    if (currentEmail !== this.lastCheckedEmail) {
      this.emailChecked = false
      this.lastCheckedEmail = ""
      this.hideMessage()
      
      if (this.hasCheckButtonTarget) {
        this.checkButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
        this.checkButtonTarget.disabled = false
        this.checkButtonTarget.textContent = "중복확인"
      }
    }
  }

  validateBeforeSubmit(event) {
    if (!this.hasEmailTarget) {
      console.error("Email target not found for validation")
      return true
    }

    const currentEmail = this.emailTarget.value.trim()
    
    // 이메일이 비어있는 경우
    if (!currentEmail) {
      event.preventDefault()
      event.stopPropagation()
      this.showMessage("⚠️ 이메일을 입력해주세요", "error")
      return false
    }

    // 중복확인을 하지 않았거나, 확인한 이메일과 다른 경우
    if (!this.emailChecked || currentEmail !== this.lastCheckedEmail) {
      event.preventDefault()
      event.stopPropagation()
      this.showMessage("⚠️ 이메일 중복확인을 해주세요", "error")
      return false
    }
    
    return true
  }

  showMessage(text, type) {
    if (!this.hasMessageTarget) {
      console.warn("Message target not found")
      return
    }
    
    this.messageTarget.textContent = text
    this.messageTarget.className = `text-sm mt-1 ${type === 'success' ? 'text-green-600 font-medium' : 'text-red-600 font-medium'}`
    this.messageTarget.classList.remove("hidden")
  }

  hideMessage() {
    if (this.hasMessageTarget) {
      this.messageTarget.classList.add("hidden")
    }
  }
}