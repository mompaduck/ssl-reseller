import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]
  connect() {
    this.isOpen = false
  }
  toggle() {
    this.isOpen = !this.isOpen
    this.menuTarget.classList.toggle("max-h-0", !this.isOpen)
    this.menuTarget.classList.toggle("opacity-0", !this.isOpen)
    this.menuTarget.classList.toggle("max-h-96", this.isOpen)
    this.menuTarget.classList.toggle("opacity-100", this.isOpen)
    this.openIconTarget.classList.toggle("hidden", this.isOpen)
    this.closeIconTarget.classList.toggle("hidden", !this.isOpen)
  }
}