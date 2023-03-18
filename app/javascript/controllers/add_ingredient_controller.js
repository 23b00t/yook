import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-ingredient"
export default class extends Controller {
  static targets = ["form", "ingredients"]

  connect() {

    console.log(this.formTarget)
    console.log(this.ingredientsTarget)
  }

  // send(event) {
  //   event.preventDefault()
  //   console.log("lol")


  //   fetch(this.formTarget.action, {
  //     method: "POST",
  //     headers: { "Accept": "application/json" },
  //     body: new FormData(this.formTarget)
  //   })
  //     .then(response => response.json())
  //     .then((data) => {
  //       if (data.inserted_item) {
  //         this.itemsTarget.insertAdjacentHTML("beforeend", data.inserted_item)
  //       }
  //       console.log("data: " + data )
  //     })
  // }
}
