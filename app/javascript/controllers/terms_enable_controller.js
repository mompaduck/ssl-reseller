// app/javascript/controllers/terms_enable_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "submitButton"]

  connect() {
    this.checkFields()
  }

  checkFields() {
    const form = this.element.closest("form")
    if (!form) return

    const nameFilled = form.querySelector("input[name='user[name]']")?.value.trim().length > 0
    const emailFilled = form.querySelector("input[name='user[email]']")?.value.trim().length > 0
    const passwordFilled = form.querySelector("input[name='user[password]']")?.value.trim().length > 0
    const termsChecked = this.checkboxTarget.checked

    if (nameFilled && emailFilled && passwordFilled && termsChecked) {
      this.submitButtonTarget.disabled = false
    } else {
      this.submitButtonTarget.disabled = true
    }
  }
}