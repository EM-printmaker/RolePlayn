import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["targetField"];

  connect() {
    this.toggle();
  }

  toggle(event) {
    // 1. 選択された値を取得
    // event があればその要素（select）から、なければ要素内から select を探す
    const select = event
      ? event.target
      : this.element.querySelector('select[name*="target_scope_type"]');
    const value = select?.value;

    if (this.hasTargetFieldTarget) {
      // 2. 判定：Railsのenum値（文字列）と一致するか確認
      const isSpecific = value === "specific_world";

      const wrapper = this.targetFieldTarget;
      const inputs = wrapper.querySelectorAll("input, select, button");

      // 見た目と操作の切り替え
      if (isSpecific) {
        wrapper.style.opacity = "1";
        wrapper.style.pointerEvents = "auto";
        inputs.forEach((i) => (i.disabled = false));
      } else {
        wrapper.style.opacity = "0.5";
        wrapper.style.pointerEvents = "none";
        inputs.forEach((i) => (i.disabled = true));

        // オプション：無効化した時に値をクリア
        const hiddenInput = wrapper.querySelector('input[type="hidden"]');
        if (hiddenInput) hiddenInput.value = "";
      }
    }
  }
}
