# Minecraft Bedrock Server Monitor & Control Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Podman または Docker 上で稼働する **Minecraft 統合版サーバー** の  
- 起動 / 停止 / 再起動 / 状態確認  
- 稼働監視 & バージョン変化検知（Discord通知付き）を自動化するスクリプト集です。

---

## 機能

### `bedrock_ctl.sh`
- `start`：サーバーを起動
- `stop`：サーバーを停止＆コンテナ削除
- `status`：現在の稼働状況を表示
- `restart`：サーバーを再起動

```bash
./bedrock_ctl.sh start
./bedrock_ctl.sh status
```

### `bedrock_status.py`
- サーバーの稼働状態を定期的にチェック
- バージョン変更を検知してDiscordに通知
- 永続化ファイルで前回バージョンを保存し、無駄な通知を防止
- .env で機密情報を分離

```ini
# .env (例)
SERVER_ADDRESS=example.minecraft.server
SERVER_PORT=19132
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/xxxx/yyyy
DISCORD_USER_ID=1234567890
VERSION_FILE=/opt/minecraft/bedrock_last_version.txt
```

## セットアップ

1. Python依存パッケージをインストール
```bash
pip install -r requirements.txt
```

2. .env を設定
```bash
cp .env.example .env
# 値を編集
```

3. 監視スクリプトを実行
```bash
python bedrock_status.py
```

## 実行例
```bash
2025-08-09 19:56:36 [INFO] 🎮 監視開始
/home/user/minecraft_scripts/bedrock_status.py:72: DeprecationWarning: 'BedrockStatusResponse.players_online' is deprecated and is expected to be removed on 2023-12, use 'players.online' instead.
  log(f"🟢 稼働中: {status.players_online}人オンライン / バージョン: {status.version.name}", "SUCCESS")
2025-08-09 19:56:36 [SUCCESS] 🟢 稼働中: 0人オンライン / バージョン: 1.21.100
・・・
```

<img width="268" height="190" alt="image" src="https://github.com/user-attachments/assets/8bbf3c71-0080-415a-9366-0dbc91570916" />

## 応用例
- サーバーの自動アップデート検知＆再起動
- 異常時の即時通知で稼働率改善
- 他のゲームサーバー監視への流用も可能

## ライセンス
MIT License
