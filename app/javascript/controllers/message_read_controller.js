import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["message", "indicator"]
    static values = {
        messageId: Number,
        ticketId: Number
    }

    connect() {
        if (this.shouldMarkAsRead()) {
            this.observeVisibility()
        }
    }

    disconnect() {
        if (this.observer) {
            this.observer.disconnect()
        }
    }

    shouldMarkAsRead() {
        // Check if message is unread and user has permission
        return this.hasIndicatorTarget &&
            this.indicatorTarget.classList.contains('unread')
    }

    observeVisibility() {
        // Use IntersectionObserver to mark as read when message is visible
        this.observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting && entry.intersectionRatio >= 0.5) {
                    // Message is more than 50% visible
                    setTimeout(() => {
                        if (entry.isIntersecting) {
                            this.markAsRead()
                        }
                    }, 1000) // Wait 1 second before marking as read
                }
            })
        }, {
            threshold: 0.5
        })

        if (this.hasMessageTarget) {
            this.observer.observe(this.messageTarget)
        }
    }

    markAsRead(event) {
        if (event) {
            event.preventDefault()
        }

        if (!this.hasMessageIdValue) return

        fetch(`/admin/ticket_messages/${this.messageIdValue}/mark_as_read`, {
            method: 'PATCH',
            headers: {
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
                'Content-Type': 'application/json'
            }
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.updateReadIndicator()
                }
            })
            .catch(error => {
                console.error('Error marking message as read:', error)
            })
    }

    updateReadIndicator() {
        if (this.hasIndicatorTarget) {
            this.indicatorTarget.classList.remove('unread')
            this.indicatorTarget.classList.add('read')
            this.indicatorTarget.textContent = '읽음'
        }

        // Disconnect observer after marking as read
        if (this.observer) {
            this.observer.disconnect()
        }
    }
}
