import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-ingredient"
export default class extends Controller {
  static targets = ["form", "item"]

  connect() {

  }

  // send(event) {
  //   event.preventDefault()
  //   console.log("ingredient eddited")


  //   var token = document.getElementsByName('csrf-token')[0].content
  //   const url = this.formTarget.action
  //   const options = {
  //     method: "PATCH",
  //     headers: {"Accept": "text/plain", "X-CSRF-Token": token},
  //     body: new FormData(this.formTarget)
  //   }
  //   fetch(url, options)
  //   .then(respond => respond.text())
  //   .then((data) => {
  //     console.log(data.my_ingredient)
  //     if (data.my_ingredient) {
  //       this.listTarget.innerHTML = data.my_ingredient
  //     }
  //   })
  // }
}
