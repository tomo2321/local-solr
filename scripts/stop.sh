#!/bin/bash

echo "🛑 Solr環境を停止しています..."

# Dockerコンテナを停止・削除
docker-compose down

echo "✅ Solr環境が停止しました。"
echo ""
echo "📝 データを完全に削除したい場合は以下を実行してください:"
echo "   docker-compose down -v  # ボリュームも削除"
echo "   docker system prune     # 未使用のDockerリソースを削除"
