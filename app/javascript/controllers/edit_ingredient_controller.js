import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-ingredient"
export default class extends Controller {
  static targets = ["form"]

  connect() {
    console.log(this.element)
    console.log(this.formTarget)
  }

}
