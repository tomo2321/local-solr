#!/bin/bash

echo "🧪 Solr検索機能をテストしています..."

echo ""
echo "1️⃣  全文検索テスト (キーワード: 'Apache')"
echo "-------------------------------------------"
curl -s "http://localhost:8983/solr/mycore/select?q=content:Apache&fl=id,title,author&rows=10" | jq '.response.docs[] | {id: .id, title: .title[0], author: .author[0]}'

echo ""
echo "2️⃣  カテゴリ検索テスト (カテゴリ: '技術書')"
echo "-------------------------------------------"
curl -s -G "http://localhost:8983/solr/mycore/select" --data-urlencode "q=category:技術書" --data-urlencode "fl=id,title,category" --data-urlencode "rows=10" | jq '.response.docs[] | {id: .id, title: .title[0], category: .category[0]}'

echo ""
echo "3️⃣  日付範囲検索テスト (2023年3月以降)"
echo "-------------------------------------------"
curl -s "http://localhost:8983/solr/mycore/select?q=published_date:[2023-03-01T00:00:00Z%20TO%20*]&fl=id,title,published_date&sort=published_date%20desc&rows=10" | jq '.response.docs[] | {id: .id, title: .title[0], published_date: .published_date[0]}'

echo ""
echo "4️⃣  タイトル検索テスト (キーワード: 'Solr')"
echo "-------------------------------------------"
curl -s "http://localhost:8983/solr/mycore/select?q=title:Solr&fl=id,title,author&rows=10" | jq '.response.docs[] | {id: .id, title: .title[0], author: .author[0]}'

echo ""
echo "5️⃣  日本語検索テスト (キーワード: '検索')"
echo "-------------------------------------------"
curl -s -G "http://localhost:8983/solr/mycore/select" --data-urlencode "q=content:検索" --data-urlencode "fl=id,title,content" --data-urlencode "rows=10" | jq '.response.docs[] | {id: .id, title: .title[0], content: .content[0]}'

echo ""
echo "6️⃣  全ドキュメント一覧"
echo "-------------------------------------------"
curl -s "http://localhost:8983/solr/mycore/select?q=*:*&fl=id,title,category&rows=10" | jq '.response.docs[] | {id: .id, title: .title[0], category: .category[0]}'

echo ""
echo "✅ 検索テストが完了しました!"
