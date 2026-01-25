import { Controller } from "@hotwire/stimulus";

export default class extends Controller {
  reset(event) {
    if (event.detail.success) {
      event.target.reset();
    }
  }
}
