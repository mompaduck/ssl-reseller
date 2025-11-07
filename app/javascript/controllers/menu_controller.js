import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]

  connect() {
    console.log("✅ menu_controller connected")
    this.boundCloseOnScroll = this.closeOnScroll.bind(this)
    this.boundCloseOnOutsideClick = this.closeOnOutsideClick.bind(this)

    window.addEventListener("scroll", this.boundCloseOnScroll)
    document.addEventListener("click", this.boundCloseOnOutsideClick)
  }

  disconnect() {
    window.removeEventListener("scroll", this.boundCloseOnScroll)
    document.removeEventListener("click", this.boundCloseOnOutsideClick)
  }

  toggle(event) {
    event.stopPropagation()
    const isOpen = this.menuTarget.classList.contains("max-h-96")

    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove("max-h-0", "opacity-0")
    this.menuTarget.classList.add("max-h-96", "opacity-100")
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
  }

  close() {
    this.menuTarget.classList.add("max-h-0", "opacity-0")
    this.menuTarget.classList.remove("max-h-96", "opacity-100")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
  }

  closeOnScroll() {
    this.close()
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}