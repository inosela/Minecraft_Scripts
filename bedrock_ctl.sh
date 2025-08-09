#!/bin/bash
# MIT License

CONTAINER_NAME="minecraft_be" # コンテナ名を指定
IMAGE="docker.io/itzg/minecraft-bedrock-server" # 統合版マインクラフト配布元（固定）
CONTAINER_DIR="/opt/minecraft" # ディレクトリを指定

start_container() {
  echo "Minecraftサーバーを起動します..."
# MEMORYは適当な値を指定
  podman run -d --name $CONTAINER_NAME \
    -v $CONTAINER_DIR:/data \
    -e EULA=TRUE \
    -e MEMORY=2G \
    -p 19132:19132/udp \
    --label io.containers.autoupdate=registry \
    --security-opt seccomp=unconfined \
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
  CONTAINER_STATUS=$(podman ps --filter "name=$CONTAINER_NAME" --format "{{.Status}}")
  if [ -n "$CONTAINER_STATUS" ]; then
    echo "Minecraftサーバーは実行中です: $CONTAINER_STATUS"
  else
    echo "Minecraftサーバーは実行されていません。"
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
case "$1" in
  start)
    start_container
    ;;
  stop)
    stop_container
    ;;
  status)
    status_container
    ;;
  restart)
    restart_container
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart}"
    exit 1
    ;;
esac
