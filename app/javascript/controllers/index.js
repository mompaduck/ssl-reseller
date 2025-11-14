// app/javascript/controllers/index.js
import { application } from "./application"

// 컨트롤러들을 직접 import 하고 등록합니다.
import MenuController from "./menu_controller.js"
application.register("menu", MenuController)

// 다른 컨트롤러들도 여기에 추가합니다.
// 예: import OtherController from "./other_controller.js"
//     application.register("other", OtherController)
