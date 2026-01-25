# GEMINI.md

## 目的
Gemini CLI 向けのコンテキストと作業方針を定義する。

## 出力スタイル
- 言語: 日本語
- トーン: 簡潔かつ直接的（CLI 環境に適したスタイル）
- 形式: GitHub Flavored Markdown

## 共通ルール
- 会話言語: 日本語
- コミット規約: Conventional Commits
- 日本語と英数字の間には半角スペースを挿入する

## プロジェクト概要
- 目的: Web Speech API を使用して、動画や音声ファイルの音声を自動的に文字起こしする。
- 主な機能: Puppeteer を使用した Chrome の自動操作、Web Speech API による文字起こし、Docker による環境構築。

## コーディング規約
- フォーマット: 既存のコードに従う
- 命名規則: キャメルケース（JavaScript）
- コメント言語: 日本語
- エラーメッセージ言語: 英語

## 開発コマンド
### Docker 操作
```bash
# イメージのビルド
docker build -t audio-transcriber .

# 実行（スクリプト経由）
./start.sh
./start-mount.sh
```

## 注意事項
- 認証情報のコミット禁止。
- ログへの機密情報出力禁止。
- 既存ルールの優先。
- Web Speech API は Chrome の機能に依存するため、Puppeteer の設定が重要。

## リポジトリ固有
- `main.js` が中心的なロジックを保持している。
- Dockerfile には Chrome や Pulseaudio のインストールが含まれており、環境構築が重要である。
