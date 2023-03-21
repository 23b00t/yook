import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-ingredient"
export default class extends Controller {

  static targets = ["form", "list"]
  connect() {
    console.log("connected")
    console.log(this.formTarget)
    console.log(this.listTarget)
    console.log(this.element)
  }

  send(event) {
    event.preventDefault()
    console.log(event)
    //console.log(this.formTarget.action)
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
      console.log(data.my_ingredient)
      this.listTarget.innerHTML += data.my_ingredient
    })
  }
}
