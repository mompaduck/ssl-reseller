import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    window.addEventListener("scroll", this.handleScroll.bind(this))
  }
  disconnect() {
    window.removeEventListener("scroll", this.handleScroll.bind(this))
  }
  handleScroll() {
    if (window.scrollY > 50) {
      this.element.classList.remove("bg-transparent")
      this.element.classList.add("bg-gradient-to-r", "from-indigo-600", "to-purple-600", "shadow-lg")
    } else {
      this.element.classList.add("bg-transparent")
      this.element.classList.remove("bg-gradient-to-r", "from-indigo-600", "to-purple-600", "shadow-lg")
    }
  }
}