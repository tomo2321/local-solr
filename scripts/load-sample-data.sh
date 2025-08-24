#!/bin/bash

echo "📊 サンプルデータを投入しています..."

# サンプルデータをSolrに投入
curl -X POST "http://localhost:8983/solr/mycore/update?commit=true" \
     -H "Content-Type: application/json" \
     -d @sample-data/documents.json

if [ $? -eq 0 ]; then
    echo "✅ サンプルデータの投入が完了しました!"
    echo ""
    echo "📈 投入されたドキュメント数を確認中..."
    curl -s "http://localhost:8983/solr/mycore/select?q=*:*&rows=0" | grep -o '"numFound":[0-9]*' | cut -d: -f2
    echo "件のドキュメントが投入されました。"
else
    echo "❌ サンプルデータの投入に失敗しました。"
    exit 1
fi

echo ""
echo "🔍 検索テスト例:"
echo "   - 全件表示: curl 'http://localhost:8983/solr/mycore/select?q=*:*'"
echo "   - 内容検索: curl 'http://localhost:8983/solr/mycore/select?q=content:Apache&fl=id,title,author'"
echo "   - カテゴリ検索: curl -G 'http://localhost:8983/solr/mycore/select' --data-urlencode 'q=category:技術書' --data-urlencode 'fl=id,title,category'"
