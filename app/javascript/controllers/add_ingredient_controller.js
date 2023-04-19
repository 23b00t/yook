import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-ingredient"
export default class extends Controller {

  static targets = ["form", "list", "flash", "new_form"]

  send(event) {
    event.preventDefault()

    var token = document.getElementsByName('csrf-token')[0].content
    const url = this.formTarget.action
    const options = {
      method: "POST",
      headers: {"Accept": "application/json", "X-CSRF-Token": token},
      body: new FormData(this.formTarget)
    }

    fetch(url, options)
    .then(respond => respond.json())
    .then((data) => {
      if (data.my_ingredient) {
        this.listTarget.innerHTML += data.my_ingredient
        this.flashTarget.innerHTML = data.my_flash
        this.new_formTarget.innerHTML = data.my_form
      } else {
        this.flashTarget.innerHTML = data.my_flash
        this.new_formTarget.innerHTML = data.my_form
      }
    })
  }
}
