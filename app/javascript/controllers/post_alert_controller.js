import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

let newPostsCount = 0;

export default class extends Controller {
  static values = { senderId: String };
  static targets = ["count"];

  connect() {
    const myId = document.querySelector(
      'meta[name="current-session-id"]',
    ).content;

    if (this.senderIdValue === myId) {
      this.element.remove();
      return;
    }

    newPostsCount++;

    if (this.hasCountTarget) {
      this.countTarget.textContent = newPostsCount;
    }
  }

  reloadAndClear(event) {
    newPostsCount = 0;
    event.preventDefault();
    this.element.innerHTML = "";
    Turbo.cache.clear();
    Turbo.visit(window.location.href, { action: "replace" });
  }
}
