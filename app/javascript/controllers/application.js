import { Application } from "@hotwired/stimulus"
import EmailCheckController from "./email_check_controller"
import PasswordConfirmController from "./password_confirm_controller"

const application = Application.start()
application.register("email-check", EmailCheckController)
application.register("password-confirm", PasswordConfirmController)

export { application }
