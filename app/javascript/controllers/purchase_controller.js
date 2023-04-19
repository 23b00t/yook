import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="purchased"
export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    this.selectedIngredients = [];
  }

  update() {
    this.selectedIngredients = [];
    this.checkboxTargets.filter((checkbox) => checkbox.checked).forEach((checkbox) => {
      this.selectedIngredients.push(checkbox.dataset.itemId);
    });
  }

  applyPurchase() {
    console.log(this.selectedIngredients);

    // Send AJAX request to purchase selected ingredients
    fetch('/grocery_ingredient', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.getElementsByName('csrf-token')[0].getAttribute('content')
      },
      body: JSON.stringify({ grocery_ingredient_ids: this.selectedIngredients })
    })
  }
}
