import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-ingredient"
export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
