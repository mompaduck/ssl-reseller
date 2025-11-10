
// app/javascript/controllers/index.js 
import { application } from "./application"


// 각 컨트롤러를 수동으로 import

import MenuController from "./menu_controller"
import EmailCheckController from "./email_check_controller"
import PasswordConfirmController from "./password_confirm_controller"
import DeleteConfirmController from "./delete_confirm_controller"
import PhoneValidateController from "./phone_validate_controller"
import ToastController from "./toast_controller"


application.register("menu", MenuController)
application.register("email-check", EmailCheckController)
application.register("phone-validate", PhoneValidateController)

application.register("delete-confirm", DeleteConfirmController)
application.register("password-confirm", PasswordConfirmController)
application.register("toast", ToastController)


export { application }

