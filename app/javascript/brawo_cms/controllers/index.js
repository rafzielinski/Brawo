import { application } from "brawo_cms/controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("brawo_cms/controllers", application)
