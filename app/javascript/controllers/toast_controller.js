// app/javascript/controllers/toast_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
      console.log("✅ toast controller connected")
    // 자동으로 5초 후 사라지게
    setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  dismiss() {
    this.element.remove()
  }
}