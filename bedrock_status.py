#!/usr/bin/env python3
# MIT License

import time
from datetime import datetime
from mcstatus import BedrockServer
import requests
from colorama import init, Fore, Style
import os
from dotenv import load_dotenv  # pip install python-dotenv

# .env読み込み
load_dotenv()

# 初期化
init()

# ====== 設定 (.envから読み込み) ======
SERVER_ADDRESS = os.getenv("SERVER_ADDRESS", "example.minecraft.server")
SERVER_PORT = int(os.getenv("SERVER_PORT", "19132"))
DISCORD_WEBHOOK_URL = os.getenv("DISCORD_WEBHOOK_URL", "")
DISCORD_USER_ID = os.getenv("DISCORD_USER_ID", "")
CHECK_INTERVAL = int(os.getenv("CHECK_INTERVAL", "30"))
VERSION_FILE = os.getenv("VERSION_FILE", "/opt/minecraft/bedrock_last_version.txt")

# ====== ログ関数 ======
def log(message, level="INFO"):
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    color = {
        "INFO": Fore.CYAN,
        "SUCCESS": Fore.GREEN,
        "ERROR": Fore.RED,
        "WARN": Fore.YELLOW,
    }.get(level, Fore.WHITE)
    print(f"{Fore.YELLOW}{now}{Style.RESET_ALL} {color}[{level}]{Style.RESET_ALL} {message}")

# ====== Discord通知 ======
def send_discord_notification(status: bool, version: str = "", version_changed=False):
    status_emoji = "🟢" if status else "🔴"
    status_text = "**オンライン**" if status else "**オフライン**"
    color_code = 0x2ECC71 if status else 0xE74C3C

    mention_line = f"<@{DISCORD_USER_ID}>" if DISCORD_USER_ID else ""

    description = f"{mention_line}\nステータス: {status_text}\nIP: `{SERVER_ADDRESS}`"
    if version:
        description += f"\nバージョン: `{version}`"
        if version_changed:
            description += "\n🔁 **バージョンが変更されました！**"

    data = {
        "embeds": [{
            "title": f"{status_emoji} MineCraft 統合版サーバー",
            "description": description,
            "color": color_code,
            "timestamp": datetime.utcnow().isoformat()
        }]
    }

    try:
        response = requests.post(DISCORD_WEBHOOK_URL, json=data)
        if response.status_code != 204:
            log(f"Discord通知失敗: {response.status_code}", "ERROR")
    except Exception as e:
        log(f"Discord通知エラー: {e}", "ERROR")

# ====== ステータス確認 ======
def check_server_status():
    try:
        server = BedrockServer.lookup(f"{SERVER_ADDRESS}:{SERVER_PORT}")
        status = server.status()
        log(f"🟢 稼働中: {status.players_online}人オンライン / バージョン: {status.version.name}", "SUCCESS")
        return True, status.version.name
    except Exception:
        log("🔴 サーバーに接続できません", "ERROR")
        return False, None

# ====== バージョン保存 ======
def load_last_version():
    if os.path.exists(VERSION_FILE):
        with open(VERSION_FILE, "r") as f:
            return f.read().strip()
    return None

def save_last_version(version):
    if version:
        with open(VERSION_FILE, "w") as f:
            f.write(version)

# ====== メイン ======
if __name__ == "__main__":
    log("🎮 監視開始")
    status_online = None
    last_version = load_last_version()

    while True:
        current_status, current_version = check_server_status()

        if status_online is None:
            status_online = current_status
            last_version = current_version
            save_last_version(current_version or "")
        else:
            version_changed = (
                current_status and current_version and current_version != last_version
            )

            if status_online != current_status or version_changed:
                send_discord_notification(current_status, current_version, version_changed)
                status_online = current_status
                if current_version:
                    last_version = current_version
                    save_last_version(current_version)

        time.sleep(CHECK_INTERVAL)
