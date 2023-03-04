import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-recipes"
export default class extends Controller {
  static targets = ["form", "input", "list"]

  update() {
    const url = `${this.formTarget.action}?query=${this.inputTarget.value}${window.location.search.replace(/[^&]+(?=&)/, '')}`
    fetch(url, {headers: {"Accept": "text/plain"}})
      .then(response => response.text())
      .then((data) => {
        this.listTarget.outerHTML = data
      })
  }
}
