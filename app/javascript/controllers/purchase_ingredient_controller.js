import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="purchase-ingredient"
export default class extends Controller {
  static targets = ["button", "element"]

  connect() {
    console.log(this.buttonTarget)
    console.log(this.elementTarget)
  }

  
}
