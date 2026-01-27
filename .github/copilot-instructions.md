# GitHub Copilot Instructions

## プロジェクト概要
- 目的: Web Speech API を使用して、動画や音声ファイルの音声を自動的に文字起こしする。
- 主な機能: Puppeteer を使用した Chrome の自動操作、Web Speech API による文字起こし、Docker による環境構築。
- 対象ユーザー: 開発者。

## 共通ルール
- 会話は日本語で行う。
- PR とコミットは Conventional Commits に従う。
- 日本語と英数字の間には半角スペースを入れる。

## 技術スタック
- 言語: Node.js (JavaScript)
- ライブラリ: Puppeteer
- インフラ: Docker, PulseAudio

## 開発コマンド
### Docker 操作
```bash
# イメージのビルド
docker build -t audio-transcriber .

# 実行（スクリプト経由）
./start.sh
./start-mount.sh
```

## コーディング規約
- コード内コメントは日本語で記載する。
- エラーメッセージは英語で記載する。
- 関数には JSDoc 形式のドキュメントを日本語で記載することを推奨する（既存コードには記載されていないため、これは新規コードに対する推奨事項であり、既存コードへの遡及適用は必須ではない）。
- フォーマットは既存のコードに従う。

## テスト方針
- 現在、自動テストは導入されていない。

## セキュリティ / 機密情報
- 認証情報や機密情報をコードに含めない。
- ログに個人情報や機密情報を出力しない。

## ドキュメント更新
- `README.md` および `README-ja.md`

## リポジトリ固有
- Chrome の Web Speech API を利用するため、Puppeteer でブラウザを起動して処理を行う。
- `paplay` を使用して仮想マイクに音声を流し込む仕組みとなっている。
- Docker コンテナ内での動作を前提としている。
