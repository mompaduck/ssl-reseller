import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
    static targets = ["count", "dropdown", "badge"]
    static values = {
        userId: Number
    }

    connect() {
        console.log("Notification controller connected")
        this.subscribe()
        this.updateBadge()
        this.observeCountChanges()
    }

    disconnect() {
        if (this.subscription) {
            this.subscription.unsubscribe()
        }
        if (this.observer) {
            this.observer.disconnect()
        }
    }

    observeCountChanges() {
        // Watch for Turbo Stream updates to the count element
        if (this.hasCountTarget) {
            this.observer = new MutationObserver(() => {
                this.updateBadge()
            })

            this.observer.observe(this.countTarget, {
                childList: true,
                characterData: true,
                subtree: true
            })
        }
    }

    subscribe() {
        // Subscribe to admin notifications channel
        this.subscription = consumer.subscriptions.create("AdminNotificationChannel", {
            connected: () => {
                console.log("Connected to AdminNotificationChannel")
            },

            disconnected: () => {
                console.log("Disconnected from AdminNotificationChannel")
            },

            received: (data) => {
                console.log("Notification received:", data)
                // Turbo Streams will handle the update automatically
                // Just update badge visibility
                setTimeout(() => this.updateBadge(), 100)
            }
        })
    }

    incrementCount() {
        if (this.hasCountTarget) {
            const currentCount = parseInt(this.countTarget.textContent) || 0
            this.countTarget.textContent = currentCount + 1
            this.updateBadge()
        }
    }

    updateBadge() {
        if (!this.hasCountTarget || !this.hasBadgeTarget) return

        const count = parseInt(this.countTarget.textContent) || 0
        if (count > 0) {
            this.badgeTarget.classList.remove("hidden")
        } else {
            this.badgeTarget.classList.add("hidden")
        }
    }

    playNotificationSound() {
        // Optional: play a subtle notification sound
        // const audio = new Audio('/sounds/notification.mp3')
        // audio.volume = 0.3
        // audio.play().catch(e => console.log('Could not play sound:', e))
    }

    showToast(data) {
        // Optional: show a toast notification
        // You can integrate with your existing notification system
        console.log("New notification:", data)
    }

    toggleDropdown(event) {
        event.preventDefault()
        if (this.hasDropdownTarget) {
            this.dropdownTarget.classList.toggle("hidden")
        }
    }

    markAllAsRead(event) {
        event.preventDefault()

        fetch('/admin/notifications/mark_all_read', {
            method: 'POST',
            headers: {
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
                'Content-Type': 'application/json'
            }
        }).then(() => {
            if (this.hasCountTarget) {
                this.countTarget.textContent = "0"
                this.updateBadge()
            }
            // Close dropdown
            if (this.hasDropdownTarget) {
                this.dropdownTarget.classList.add("hidden")
            }
        })
    }
}
