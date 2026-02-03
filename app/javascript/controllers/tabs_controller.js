import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["pane", "link"];

  connect() {
    this.showTab(this.data.get("defaultTab") || "emotions");
  }

  change(event) {
    event.preventDefault();
    const tabName = event.currentTarget.dataset.tabName;
    this.showTab(tabName);
  }

  showTab(tabName) {
    // パネルの表示・非表示
    this.paneTargets.forEach((pane) => {
      pane.classList.toggle("d-none", pane.dataset.tabName !== tabName);
    });

    // タブの見た目（activeクラス）の切り替え
    this.linkTargets.forEach((link) => {
      link.classList.toggle("active", link.dataset.tabName === tabName);
    });
  }
}
