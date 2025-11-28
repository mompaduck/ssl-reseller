import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
    static targets = ["ordersCount", "ticketsCount", "certificatesCount", "recentOrders"]

    connect() {
        console.log("Realtime dashboard controller connected")
        this.subscribe()
        this.setupTurboStreamListener()
    }

    disconnect() {
        if (this.subscription) {
            this.subscription.unsubscribe()
        }
        if (this.turboStreamListener) {
            document.removeEventListener("turbo:before-stream-render", this.turboStreamListener)
        }
    }

    setupTurboStreamListener() {
        // Listen for Turbo Stream updates and reinitialize icons
        this.turboStreamListener = (event) => {
            // After Turbo Stream renders, reinitialize Lucide icons
            setTimeout(() => {
                if (typeof lucide !== 'undefined') {
                    lucide.createIcons()
                    console.log("Lucide icons reinitialized after Turbo Stream update")
                }
            }, 10)
        }

        document.addEventListener("turbo:before-stream-render", this.turboStreamListener)
    }

    subscribe() {
        this.subscription = consumer.subscriptions.create("DashboardChannel", {
            connected: () => {
                console.log("Connected to DashboardChannel")
            },

            disconnected: () => {
                console.log("Disconnected from DashboardChannel")
            },

            received: (data) => {
                console.log("Dashboard update received:", data)
                // Turbo Streams will handle the updates automatically
                this.animateUpdate(data)
            }
        })
    }

    animateUpdate(data) {
        // Add a subtle animation when counters update
        if (data.type === 'counter_update') {
            const target = this.targets.find(data.target)
            if (target) {
                target.classList.add('flash')
                setTimeout(() => {
                    target.classList.remove('flash')
                }, 500)
            }
        }
    }
}
