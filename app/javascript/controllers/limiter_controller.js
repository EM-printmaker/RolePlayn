import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "submit", "counter"];
  static values = {
    charMax: Number, // 文字数の上限
    lineMax: Number, // 改行数の上限
  };

  connect() {
    this.check(); // ページ読み込み時にもチェック
  }

  check() {
    const text = this.inputTarget.value;
    const charCount = text.length;
    // 改行の数をカウント (splitして配列の長さ-1)
    const lineCount = (text.match(/\n/g) || []).length;

    // 判定ロジック
    const isCharOver = charCount > this.charMaxValue;
    const isLineOver = lineCount > this.lineMaxValue;
    const isInvalid = isCharOver || isLineOver;

    // 1. カウンターの表示更新（現在非表示）
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${charCount}/${this.charMaxValue}`;

      // カウンター自体の色を変える
      if (isInvalid) {
        this.counterTarget.classList.add("text-danger", "fw-bold");
        this.counterTarget.classList.remove("text-muted");
      } else {
        this.counterTarget.classList.remove("text-danger", "fw-bold");
        this.counterTarget.classList.add("text-muted");
      }
    }

    // 2. テキストエリアの見た目を変える
    if (isInvalid) {
      this.inputTarget.classList.add("is-invalid-custom");
    } else {
      this.inputTarget.classList.remove("is-invalid-custom");
    }

    // 3. 送信ボタンの無効化 (disabled)
    this.submitTarget.disabled = isInvalid;
  }
}
