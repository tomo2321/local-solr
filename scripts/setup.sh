#!/bin/bash

echo "🚀 Solr環境をセットアップしています..."

# Dockerコンテナを起動
echo "📦 Dockerコンテナを起動中..."
docker-compose up -d

# Solrが起動するまで待機
echo "⏳ Solrが起動するまで待機中..."
sleep 30

# Solrの状態をチェック
echo "🔍 Solr接続をチェック中..."
max_attempts=10
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:8983/solr/admin/cores?action=STATUS > /dev/null; then
        echo "✅ Solrに正常に接続できました!"
        break
    else
        echo "⏳ 接続試行 $attempt/$max_attempts..."
        sleep 10
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Solrへの接続に失敗しました。"
    exit 1
fi

echo ""
echo "🎉 Solr環境のセットアップが完了しました!"
echo ""
echo "📍 アクセス情報:"
echo "   - Solr管理画面: http://localhost:8983/solr/"
echo "   - デフォルトコア: mycore"
echo "   - Solrバージョン: 8.11"
echo ""
echo "🔧 次のステップ:"
echo "   1. サンプルデータを投入: ./scripts/load-sample-data.sh"
echo "   2. 検索テスト: ./scripts/test-search.sh"
