#!/bin/bash
# MIT License

CONTAINER_NAME="minecraft_be" # コンテナ名を指定
IMAGE="docker.io/itzg/minecraft-bedrock-server" # 統合版マインクラフト配布元（固定）
CONTAINER_DIR="/opt/minecraft" # ディレクトリを指定
PORT="19132/udp"

start_container() {
  echo "Minecraftサーバーを起動します..."
  # memoryは適当な値を指定
  mkdir -p "$CONTAINER_DIR"
  podman run -d --name "$CONTAINER_NAME" \
    -v "$CONTAINER_DIR":/data \
    -e EULA=TRUE \
    -p "$PORT" \
    --label io.containers.autoupdate=registry \
    --security-opt seccomp=unconfined \
    --memory=2g
    $IMAGE
  echo "Minecraftサーバーが起動しました。"
}

stop_container() {
  echo "Minecraftサーバーを停止します..."
  podman stop $CONTAINER_NAME
  podman rm $CONTAINER_NAME
  echo "Minecraftサーバーが停止しました。"
}

status_container() {
  if exists; then
    state="$(podman inspect -f '{{.State.Status}}' "$CONTAINER_NAME")"
    echo "Status: $state"
  else
    echo "Status: Minecraftサーバーは実行されていません。"
  fi
}

restart_container() {
  echo "Minecraftサーバーを再起動します..."
  stop_container
  sleep 30
  start_container
  echo "Minecraftサーバーが再起動しました。"
}

# ./bedrock_ctl.sh start   - コンテナをpodman runで起動
# ./bedrock_ctl.sh stop    - コンテナをpodman rmで削除
# ./bedrock_ctl.sh status  - 現在のコンテナ状況を確認
# ./bedrock_ctl.sh restart - コンテナをpodman restartで再起動
case "${1:-}" in
  start)   start_container ;;
  stop)    stop_container ;;
  status)  status_container ;;
  restart) restart_container ;;
  *) usage ;;
esac
