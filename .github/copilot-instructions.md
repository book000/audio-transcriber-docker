# GitHub Copilot Instructions

GitHub Copilot によるコードレビュー時の判断基準を示す。

## プロジェクト概要
- Puppeteer で Chrome を自動操作し、Web Speech API（`webkitSpeechRecognition`）で動画・音声ファイルを文字起こしする Docker アプリケーション。
- 技術スタック: Node.js (JavaScript) / Puppeteer / Docker / PulseAudio。テストフレームワークは未導入。

## レビュー時の重点確認事項
- コミット・PR タイトルが Conventional Commits に従っているか。
- 日本語と英数字の間に半角スペースが入っているか。
- コード内コメントが日本語、エラーメッセージが英語で書かれているか。
- 新規関数に日本語の JSDoc が付いているか（新規コードへの推奨。既存コードへの遡及適用は不要）。
- 認証情報・機密情報がコードに含まれていないか、ログに個人情報・機密情報を出力していないか。
- 挙動を変える変更で `README.md` / `README-ja.md` の更新漏れがないか。

## 誤検知しやすい・フラグすべきでないパターン
- `main.js` の `page.evaluate()` 内コードはブラウザコンテキストで実行される。`webkitSpeechRecognition` や `recognition` 等の未宣言グローバルは意図的であり、Node.js 側の未定義参照として指摘しない。
- Puppeteer 起動時の `--no-sandbox` は Docker コンテナ内での実行を前提とした意図的な設定であり、セキュリティ問題として一律に指摘しない。
- snake_case（例: `start_recognition`）と camelCase（例: `toHHMMSS`）の混在は既存コードの方針であり、命名の不統一として指摘しない。
- フォーマットは既存コードに合わせる方針のため、スタイルのみの差異は指摘しない。

## リポジトリ固有の前提
- 音声は `paplay` で PulseAudio の仮想マイク（`MicOutput`）へ流し込み、Chrome の Web Speech API で認識する。この入出力経路が動作の前提となる。
- Docker コンテナ内での動作を前提としている。
