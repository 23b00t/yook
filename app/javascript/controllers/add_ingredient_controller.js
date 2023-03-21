import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-ingredient"
export default class extends Controller {

  static targets = ["form", "list", "document"]
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
      } else {
        alert("You already have this ingredient in Fridge! please change the quantity manualy!")
      }
    })
  }
}
