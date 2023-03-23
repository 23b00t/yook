import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-ingredient"
export default class extends Controller {
  static targets = ["form", "item"]

  connect() {
    console.log(this.formTarget)
    console.log(this.itemTarget)
  }

  send(event) {
    event.preventDefault()

    console.log(new FormData(this.formTarget))

    var token = document.getElementsByName('csrf-token')[0].content
    const url = this.formTarget.action
    const options = {
      method: "PATCH",
      headers: {"Accept": "text/plain", "X-CSRF-Token": token},
      body: new FormData(this.formTarget)
    }
    fetch(url, options)
    .then(response => response.text())
    .then((data) => {
      this.itemTarget.outerHTML = data
    })
  }

}
