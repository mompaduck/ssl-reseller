// app/javascript/controllers/faq_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("✅ faq controller connected")
  }

  toggle(event) {
    const button = event.currentTarget
    const faqItem = button.closest('.faq-item')
    const answer = faqItem.querySelector('div')
    const icon = button.querySelector('svg')
    
    // 답변 토글
    answer.classList.toggle('hidden')
    
    // 아이콘 회전
    icon.classList.toggle('rotate-180')
    
    // 배경색 변경
    if (!answer.classList.contains('hidden')) {
      button.classList.add('bg-gray-50')
    } else {
      button.classList.remove('bg-gray-50')
    }
  }
}