import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["pane", "link"];

  connect() {
    this.currentTab = this.data.get("defaultTab") || "emotions";
    this.showTab(this.currentTab);
  }

  change(event) {
    const tabName = event.currentTarget.dataset.tabName;
    this.currentTab = tabName;
    this.showTab(tabName);
  }

  showTab(tabName) {
    // パネルの表示・非表示
    this.paneTargets.forEach((pane) => {
      const isActive = pane.dataset.tabName === tabName;
      pane.classList.toggle("d-none", !isActive);
      // ★ 追加：お気に入りタブが表示された時、Turbo Frameを最新に更新する
      if (isActive && tabName === "favorites") {
        this.reloadFavorites(pane);
      }
    });
    // タブの見た目（activeクラス）の切り替え
    this.linkTargets.forEach((link) => {
      link.classList.toggle("active", link.dataset.tabName === tabName);
    });
  }

  reloadFavorites(pane) {
    const frame =
      pane.tagName === "TURBO-FRAME" ? pane : pane.querySelector("turbo-frame");
    if (frame && frame.src) {
      frame.reload();
    }
  }

  // フォーム送信時に現在のタブ情報を注入
  submitWithTab(event) {
    const form = event.currentTarget.closest("form");

    if (!form) {
      return;
    }

    const tabValue = this.currentTab || "emotions";

    let input = form.querySelector('input[name="tab"]');
    if (!input) {
      input = document.createElement("input");
      input.type = "hidden";
      input.name = "tab";
      form.appendChild(input);
    }

    input.value = tabValue;
  }
}
