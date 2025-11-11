// app/javascript/controllers/phone_validate_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // 컨트롤러가 연결될 때 (페이지 로드 시) 현재 입력 필드의 값을 포맷팅
    if (this.hasInputTarget) {
      this.inputTarget.value = this._formatNumber(this.inputTarget.value);
    }
  }

  // 사용자가 입력할 때마다 호출되는 액션
  format(event) {
    event.target.value = this._formatNumber(event.target.value);
  }

  // 전화번호 포맷팅을 처리하는 내부 메소드
  _formatNumber(value) {
    if (!value) return "";
    
    let numbers = value.replace(/[^\d]/g, '');
    if (numbers.length > 11) {
      numbers = numbers.slice(0, 11);
    }
    
    let formatted = '';
    if (numbers.length <= 3) {
      formatted = numbers;
    } else if (numbers.length <= 7) {
      formatted = `${numbers.slice(0, 3)}-${numbers.slice(3)}`;
    } else if (numbers.length <= 10) {
      formatted = `${numbers.slice(0, 3)}-${numbers.slice(3, 6)}-${numbers.slice(6)}`;
    } else {
      formatted = `${numbers.slice(0, 3)}-${numbers.slice(3, 7)}-${numbers.slice(7)}`;
    }
    
    return formatted;
  }

  validate(event) {
    const value = event.target.value;
    if (value === '') return;

    const numbers = value.replace(/[^\d]/g, '');
    const phoneRegex10 = /^01[016789]-\d{3}-\d{4}$/;
    const phoneRegex11 = /^01[016789]-\d{4}-\d{4}$/;
    
    if (numbers.length < 10) {
      this._showToast("전화번호가 너무 짧습니다", "alert");
    } else if (numbers.length > 11) {
      this._showToast("전화번호가 너무 깁니다", "alert");
    } else if (!phoneRegex10.test(value) && !phoneRegex11.test(value)) {
      this._showToast("올바른 전화번호 형식이 아닙니다", "alert");
    }
  }

  // 토스트 메시지를 동적으로 생성하는 메소드
  _showToast(message, type = 'notice') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const details = this._getToastDetails(type);

    const toastElement = document.createElement('div');
    toastElement.id = `toast-${Date.now()}`;
    toastElement.dataset.controller = "toast";
    toastElement.className = `${details.bg_class} text-white px-6 py-4 rounded-lg shadow-lg flex items-center space-x-3 max-w-md animate-slide-in`;
    toastElement.setAttribute('role', 'alert');
    
    toastElement.innerHTML = `
      <svg class="w-6 h-6 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${details.icon}"/>
      </svg>
      <p class="font-medium flex-1">${message}</p>
      <button data-action="click->toast#dismiss" class="ml-2 ${details.hover_bg_class} rounded p-1 transition flex-shrink-0">
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>
        </svg>
      </button>
    `;

    container.appendChild(toastElement);
  }

  _getToastDetails(type) {
    switch (type) {
      case 'notice':
        return {
          bg_class: 'bg-green-500',
          hover_bg_class: 'hover:bg-green-600',
          icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
        };
      case 'alert':
        return {
          bg_class: 'bg-red-500',
          hover_bg_class: 'hover:bg-red-600',
          icon: 'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z'
        };
      default:
        return {
          bg_class: 'bg-gray-500',
          hover_bg_class: 'hover:bg-gray-600',
          icon: 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
        };
    }
  }
}