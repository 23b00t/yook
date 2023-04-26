import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="purchased"
export default class extends Controller {
  static targets = ["checkbox", "list"]

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
    // Send AJAX request to purchase selected ingredients
    fetch('/grocery_ingredient', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.getElementsByName('csrf-token')[0].getAttribute('content')
      },
      body: JSON.stringify({ grocery_ingredient_ids: this.selectedIngredients })
    })
    .then(response => response.json())
    .then(data => {
      if (data.alert) {
        alert(data.alert);
      } else {
        alert(data.notice);
        this.updateList();
      }
    });
  }

  updateList() {
    fetch('/grocery_ingredients', {headers: {"Accept": "text/plain"}})
    .then(response => response.text())
    .then((data) => {
      this.listTarget.outerHTML = data
    })
  }

  selectAll() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = true;
    });
    this.update();
  }
}
