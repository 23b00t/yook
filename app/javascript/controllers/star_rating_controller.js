import { Controller } from "@hotwired/stimulus"
import StarRating from "star-rating.js"

export default class extends Controller {
  connect() {
    console.log(this.element.nextElementSibling.innerHTML)
    new StarRating(this.element)
    this.element.nextElementSibling.innerHTML = "<span class='gl-star-rating--stars s0' role='tooltip' data-rating='0' aria-label=''>"
  }
}
