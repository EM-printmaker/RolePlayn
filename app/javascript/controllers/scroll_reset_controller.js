import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { timestamp: Number };

  timestampValueChanged() {
    this.scrollToTop();
  }

  scrollToTop() {
    window.scrollTo({
      top: 0,
      behavior: "smooth",
    });
  }
}
