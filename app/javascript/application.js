import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"

// Start Stimulus
const application = Application.start()
window.Stimulus = application

// Configure Stimulus development experience
application.debug = false

// Import and register all your controllers
import AutoDismissController from "./controllers/auto_dismiss_controller.js"
application.register("auto-dismiss", AutoDismissController)

import DeleteConfirmController from "./controllers/delete_confirm_controller.js"
application.register("delete-confirm", DeleteConfirmController)

import EmailCheckController from "./controllers/email_check_controller.js"
application.register("email-check", EmailCheckController)

import FaqController from "./controllers/faq_controller.js"
application.register("faq", FaqController)

import HelloController from "./controllers/hello_controller.js"
application.register("hello", HelloController)

import MenuController from "./controllers/menu_controller.js"
application.register("menu", MenuController)

import PasswordConfirmController from "./controllers/password_confirm_controller.js"
application.register("password-confirm", PasswordConfirmController)

import PasswordFormController from "./controllers/password_form_controller.js"
application.register("password-form", PasswordFormController)

import PhoneValidateController from "./controllers/phone_validate_controller.js"
application.register("phone-validate", PhoneValidateController)

import TermsEnableController from "./controllers/terms_enable_controller.js"
application.register("terms-enable", TermsEnableController)

export { application }
