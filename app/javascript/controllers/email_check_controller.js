import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "email",
    "emailMessage",
    "password",
    "passwordConfirmation",
    "passwordMessage"
  ]

  connect() {
    this.emailChecked = false
  }

  emailChanged() {
    // 이메일을 바꾸면 다시 중복확인 해야 함
    this.emailChecked = false
    this.emailMessageTarget.textContent = "이메일 변경됨 — 다시 중복확인을 해주세요."
    this.emailMessageTarget.className = "text-sm mt-1 text-orange-600"
  }

  async checkEmail() {
    const email = this.emailTarget.value.trim()

    if (!email) {
      this.showEmailMessage("이메일을 입력해주세요.", "text-red-600")
      this.emailChecked = false
      return
    }

    try {
      const response = await fetch(`/users/check_email?email=${encodeURIComponent(email)}`)
      const data = await response.json()

      if (data.exists) {
        this.showEmailMessage("⚠️ 이미 사용 중인 이메일입니다.", "text-red-600")
        this.emailChecked = false
      } else {
        this.showEmailMessage("✅ 사용 가능한 이메일입니다.", "text-green-600")
        this.emailChecked = true
      }
    } catch (error) {
      console.error(error)
      this.showEmailMessage("이메일 확인 중 오류가 발생했습니다.", "text-red-600")
      this.emailChecked = false
    }
  }

  validateBeforeSubmit(event) {
    let valid = true

    // 1) 이메일 중복확인 안했으면 막기
    if (!this.emailChecked) {
      this.showEmailMessage("⚠️ 이메일 중복 확인을 해주세요.", "text-red-600")
      valid = false
    }

    // 2) 비밀번호 검사
    const pwd  = this.passwordTarget.value.trim()
    const pwd2 = this.passwordConfirmationTarget.value.trim()
    let pwdMsg = ""
    let pwdClass = "text-sm mb-2 "

    if (!pwd) {
      pwdMsg = "비밀번호를 입력해주세요."
      pwdClass += "text-red-600"
      valid = false
    } else if (pwd.length < 8) {
      pwdMsg = "비밀번호는 8자 이상이어야 합니다."
      pwdClass += "text-red-600"
      valid = false
    } else if (!pwd2) {
      pwdMsg = "비밀번호 확인을 입력해주세요."
      pwdClass += "text-red-600"
      valid = false
    } else if (pwd !== pwd2) {
      pwdMsg = "비밀번호와 비밀번호 확인이 일치하지 않습니다."
      pwdClass += "text-red-600"
      valid = false
    } else {
      pwdMsg = "✅ 비밀번호가 확인되었습니다."
      pwdClass += "text-green-600"
    }

    this.passwordMessageTarget.textContent = pwdMsg
    this.passwordMessageTarget.className = pwdClass

    if (!valid) {
      event.preventDefault()
      // 첫 문제 위치로 스크롤
      window.scrollTo({
        top: this.emailTarget.offsetTop - 120,
        behavior: "smooth"
      })
    }
  }

  showEmailMessage(text, colorClass) {
    this.emailMessageTarget.textContent = text
    this.emailMessageTarget.className = `text-sm mt-1 ${colorClass}`
  }
}