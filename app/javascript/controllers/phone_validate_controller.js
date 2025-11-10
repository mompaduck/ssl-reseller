// app/javascript/controllers/phone_validate_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "message"]

  connect() {
    console.log("✅ phone-validate controller connected")
    /*
    console.log("📞 phone-validate controller connected",
                "hasInputTarget =", this.hasInputTarget,
                "hasMessageTarget =", this.hasMessageTarget)
    // 연결 확인
    if (this.hasInputTarget) {
      console.log("✅ input target found")
    } else {
      console.error("❌ input target NOT found")
    }
      */
  }

  

  format(event) {
    let value = event.target.value
    
    // 숫자만 추출
    let numbers = value.replace(/[^\d]/g, '')
    
    // 최대 11자리로 제한
    if (numbers.length > 11) {
      numbers = numbers.slice(0, 11)
    }
    
    // 하이픈 자동 삽입
    let formatted = ''
    if (numbers.length <= 3) {
      formatted = numbers
    } else if (numbers.length <= 7) {
      formatted = numbers.slice(0, 3) + '-' + numbers.slice(3)
    } else if (numbers.length <= 10) {
      // 010-123-4567 형식 (10자리)
      formatted = numbers.slice(0, 3) + '-' + numbers.slice(3, 6) + '-' + numbers.slice(6)
    } else {
      // 010-1234-5678 형식 (11자리)
      formatted = numbers.slice(0, 3) + '-' + numbers.slice(3, 7) + '-' + numbers.slice(7)
    }
    
    // 포맷된 값을 입력 필드에 설정
    event.target.value = formatted
    
 // console.log("Formatted:", formatted)
  }

  validate(event) {
    const value = event.target.value
    const numbers = value.replace(/[^\d]/g, '')
    
    if (value === '') {
      this.hideMessage()
      return
    }
    
    // 한국 전화번호 검증
    // 010-1234-5678 (11자리) 또는 010-123-4567 (10자리)
    const phoneRegex10 = /^01[016789]-\d{3}-\d{4}$/  // 10자리
    const phoneRegex11 = /^01[016789]-\d{4}-\d{4}$/  // 11자리
    
    if (numbers.length < 10) {
      this.showMessage("전화번호가 너무 짧습니다", "error")
    } else if (numbers.length > 11) {
      this.showMessage("전화번호가 너무 깁니다", "error")
    } else if (!phoneRegex10.test(value) && !phoneRegex11.test(value)) {
      this.showMessage("올바른 전화번호 형식이 아닙니다", "error")
    } else {
      this.showMessage("✓ 올바른 전화번호입니다", "success")
    }
  }

  showMessage(text, type) {
    if (!this.hasMessageTarget) {
      console.warn("Message target not found")
      return
    }
    
    this.messageTarget.textContent = text
    this.messageTarget.className = `text-xs mt-2 ${type === 'success' ? 'text-green-600 font-medium' : 'text-red-600 font-medium'}`
    this.messageTarget.classList.remove("hidden")
  }

  hideMessage() {
    if (!this.hasMessageTarget) return
    this.messageTarget.classList.add("hidden")
  }

  validateBeforeSubmit(event) {
  if (!this.hasInputTarget) return true;

  const raw = this.inputTarget.value.replace(/\D/g, '');
  const mobilePattern = /^01[0-9]{8,9}$/;

  if (raw.length === 0) {
    event.preventDefault(); event.stopPropagation();
    this.showMessage("전화번호를 입력해주세요", "error");
    this.inputTarget.focus();
    return false;
  }
  if (!mobilePattern.test(raw)) {
    event.preventDefault(); event.stopPropagation();
    this.showMessage("올바른 전화번호를 입력해주세요", "error");
    this.inputTarget.focus();
    return false;
  }
  return true;
}

  /*
  validateBeforeSubmit(event) {
    if (!this.hasInputTarget) {
      return true
    }
    const raw = this.inputTarget.value.replace(/[^0-9]/g, '')
    if (raw.length === 0) {
      event.preventDefault()
      event.stopPropagation()
      this.showError()
      this.inputTarget.focus()
      return false
    }
    const mobilePattern = /^01[0-9]{8,9}$/
    const phonePattern  = /^(0(2|3[1-3]|4[1-4]|5[1-5]|6[1-4]))[0-9]{7,8}$/
    if (!(mobilePattern.test(raw) || phonePattern.test(raw))) {
      event.preventDefault()
      event.stopPropagation()
      this.showError()
      this.inputTarget.focus()
      return false
    }
    return true
    
  }
    */

}