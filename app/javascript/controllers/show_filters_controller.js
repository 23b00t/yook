import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-filters"
export default class extends Controller {
  static targets = ["button"]

  displayForm() {
    this.buttonTarget.classList.toggle("d-none")
  }
}
