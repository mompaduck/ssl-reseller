import { Application } from "@hotwired/stimulus"
import MenuController from "./menu_controller"
import EmailCheckController from "./email_check_controller"

// Stimulus 시작 (한 번만!)
const application = Application.start()

// 컨트롤러 등록
application.register("menu", MenuController)
application.register("email-check", EmailCheckController)