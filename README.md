# ローカル Apache Solr 環境

このプロジェクトは、Docker Compose を使用してローカルで Apache Solr の検索環境を簡単に構築・管理するためのセットアップです。

## 📋 使用バージョン

- **Apache Solr**: 8.11.x (Docker イメージ: `solr:8.11-slim`)
- **Apache Lucene**: 8.11.x (Solr に内蔵)
- **Java**: OpenJDK 11 (Docker イメージに内蔵)
- **Docker Compose**: 最新版

> **注意**: Solr 9.x 系では configset の問題により起動エラーが発生する場合があります。
> 本環境では安定した Solr 8.11 系 を採用しています。

## 🚀 クイックスタート

### 前提条件

- Docker Desktop がインストールされていること
- `jq` コマンド（検索テスト用、オプション）
  ```bash
  brew install jq  # macOSの場合
  ```

### 1. 環境構築

```bash
# Solr環境を起動
./scripts/setup.sh
```

### 2. サンプルデータの投入

```bash
# サンプルドキュメントをSolrに投入
./scripts/load-sample-data.sh
```

### 3. 検索テスト

```bash
# 各種検索機能をテスト
./scripts/test-search.sh
```

## 📁 プロジェクト構造

```
local-solr/
├── docker-compose.yml          # Docker Compose設定
├── scripts/                    # 管理用スクリプト
│   ├── setup.sh               # 環境セットアップ
│   ├── load-sample-data.sh     # サンプルデータ投入
│   ├── test-search.sh          # 検索テスト
│   └── stop.sh                 # 環境停止
├── sample-data/                # サンプルデータ
│   └── documents.json          # サンプルドキュメント
├── solr-data/                  # Solrデータディレクトリ
├── configsets/                 # Solr設定
└── cores/                      # Solrコア
```

## 🔗 アクセス情報

- **Solr 管理画面**: http://localhost:8983/solr/
- **デフォルトコア**: `mycore`
- **Solr バージョン**: 8.11 系
- **Lucene バージョン**: 8.11 系
- **API エンドポイント**: http://localhost:8983/solr/mycore/
- **システム情報**: http://localhost:8983/solr/admin/info/system

## 🛠 基本的な使い方

### Solr 管理画面へのアクセス

ブラウザで http://localhost:8983/solr/ にアクセスすると、Solr の管理画面が表示されます。
「Core Admin」から `mycore` を選択して、データの確認や管理ができます。

### コマンドラインからの検索

#### 1. 基本検索（内容フィールド）

```bash
# Apacheを含むドキュメントを検索
curl "http://localhost:8983/solr/mycore/select?q=content:Apache&fl=id,title,author"

# 結果例：Apache Solr入門、Luceneの内部構造
```

#### 2. フィールド指定検索

```bash
# 技術書カテゴリのドキュメントを検索
curl -G "http://localhost:8983/solr/mycore/select" \
     --data-urlencode "q=category:技術書" \
     --data-urlencode "fl=id,title,category"

# タイトルにSolrを含むドキュメントを検索
curl "http://localhost:8983/solr/mycore/select?q=title:Solr&fl=id,title,author"
```

#### 3. 日付範囲検索

```bash
# 2023年3月以降に公開されたドキュメント
curl "http://localhost:8983/solr/mycore/select?q=published_date:[2023-03-01T00:00:00Z%20TO%20*]&fl=id,title,published_date&sort=published_date%20desc"
```

#### 4. 日本語検索

```bash
# 日本語キーワードで検索（URLエンコード使用）
curl -G "http://localhost:8983/solr/mycore/select" \
     --data-urlencode "q=content:検索" \
     --data-urlencode "fl=id,title,content"
```

#### 5. 複合検索

```bash
# AND検索：技術書かつ内容にApacheを含む
curl -G "http://localhost:8983/solr/mycore/select" \
     --data-urlencode "q=category:技術書 AND content:Apache" \
     --data-urlencode "fl=id,title,category"

# OR検索：技術書または入門書
curl -G "http://localhost:8983/solr/mycore/select" \
     --data-urlencode "q=category:技術書 OR category:入門書" \
     --data-urlencode "fl=id,title,category"
```

### データの投入

#### JSON ファイルから一括投入

```bash
curl -X POST "http://localhost:8983/solr/mycore/update?commit=true" \
     -H "Content-Type: application/json" \
     -d @your-data.json
```

#### 単一ドキュメントの投入

```bash
curl -X POST "http://localhost:8983/solr/mycore/update?commit=true" \
     -H "Content-Type: application/json" \
     -d '[
       {
         "id": "new-doc",
         "title": "新しいドキュメント",
         "content": "ここに内容を記述",
         "category": "新規",
         "author": "作成者名",
         "published_date": "2023-08-24T00:00:00Z"
       }
     ]'
```

#### データの削除

```bash
# 特定ドキュメントの削除
curl -X POST "http://localhost:8983/solr/mycore/update?commit=true" \
     -H "Content-Type: application/json" \
     -d '{"delete":{"id":"doc-id-to-delete"}}'

# 全データの削除
curl -X POST "http://localhost:8983/solr/mycore/update?commit=true" \
     -H "Content-Type: application/json" \
     -d '{"delete":{"query":"*:*"}}'
```

#### データの更新

```bash
# 既存ドキュメントの更新（同じIDで再投入）
curl -X POST "http://localhost:8983/solr/mycore/update?commit=true" \
     -H "Content-Type: application/json" \
     -d '[
       {
         "id": "1",
         "title": "更新されたタイトル",
         "content": "更新された内容",
         "category": "更新カテゴリ"
       }
     ]'
```

## 📊 サンプルデータについて

`sample-data/documents.json`には以下のフィールドを持つサンプルドキュメントが含まれています：

- `id`: ドキュメント ID（必須、一意）
- `title`: タイトル
- `content`: 内容（検索対象の主要フィールド）
- `category`: カテゴリ（ファセット検索用）
- `author`: 著者
- `published_date`: 公開日（日付範囲検索用）

### サンプルデータ一覧

| ID  | タイトル              | カテゴリ | 著者     | 公開日     |
| --- | --------------------- | -------- | -------- | ---------- |
| 1   | Apache Solr 入門      | 技術書   | 田中太郎 | 2023-01-15 |
| 2   | Elasticsearch vs Solr | 比較記事 | 佐藤花子 | 2023-02-20 |
| 3   | 全文検索の基礎        | 入門書   | 山田次郎 | 2023-03-10 |
| 4   | Lucene の内部構造     | 技術書   | 鈴木一郎 | 2023-04-05 |
| 5   | 検索精度の向上        | 実践書   | 高橋美咲 | 2023-05-12 |

### フィールドタイプと検索方法

- **テキストフィールド**（title, content, author）: 部分マッチ検索可能
- **キーワードフィールド**（category）: 完全マッチ検索
- **日付フィールド**（published_date）: 範囲検索、ソート可能

## 🔧 カスタマイズ

### Docker Compose 設定

現在の設定は以下のとおりです：

```yaml
services:
  solr:
    image: solr:8.11-slim # Apache Solr 8.11系 + Apache Lucene 8.11系
    container_name: local-solr
    ports:
      - "8983:8983"
    volumes:
      - solr-data:/var/solr
    environment:
      - SOLR_HEAP=512m
    command:
      - solr-precreate
      - mycore
    restart: unless-stopped
```

### 新しいコアの作成

```bash
# Solrコンテナ内で新しいコアを作成
docker exec -it local-solr solr create_core -c newcore

# 作成後の確認
curl "http://localhost:8983/solr/admin/cores?action=STATUS"
```

### メモリ設定の調整

大量のデータを扱う場合は、メモリを増やしてください：

```yaml
environment:
  - SOLR_HEAP=1g # 1GBに増加
  # または
  - SOLR_HEAP=2g # 2GBに増加
```

### ポート変更

別のポートを使用したい場合：

```yaml
ports:
  - "8984:8983" # 8984ポートに変更する例
```

変更後は以下の URL でアクセス：

- 管理画面: http://localhost:8984/solr/
- API: http://localhost:8984/solr/mycore/select?q=_:_

### 永続化データの場所

Solr のデータは名前付きボリューム `solr-data` に保存されます：

```bash
# ボリュームの確認
docker volume ls | grep solr

# ボリュームの詳細情報
docker volume inspect local-solr_solr-data
```

## 💡 実践的な使用例

### ブログ記事検索システム

```bash
# 1. ブログ記事データの投入
curl -X POST "http://localhost:8983/solr/mycore/update?commit=true" \
     -H "Content-Type: application/json" \
     -d '[
       {
         "id": "blog001",
         "title": "Docker入門ガイド",
         "content": "Dockerの基本的な使い方を解説します...",
         "category": "技術",
         "author": "開発者A",
         "published_date": "2023-08-01T00:00:00Z",
         "tags": ["Docker", "Container", "DevOps"]
       }
     ]'

# 2. キーワード検索
curl -G "http://localhost:8983/solr/mycore/select" \
     --data-urlencode "q=content:Docker" \
     --data-urlencode "fl=id,title,author,published_date"

# 3. カテゴリ別一覧
curl -G "http://localhost:8983/solr/mycore/select" \
     --data-urlencode "q=category:技術" \
     --data-urlencode "sort=published_date desc" \
     --data-urlencode "rows=10"
```

### 商品検索システム

```bash
# 商品データの例
curl -X POST "http://localhost:8983/solr/mycore/update?commit=true" \
     -H "Content-Type: application/json" \
     -d '[
       {
         "id": "prod001",
         "title": "ワイヤレスマウス",
         "content": "高精度なワイヤレスマウス。長時間使用可能。",
         "category": "PC周辺機器",
         "price": 2980,
         "brand": "TechCorp",
         "in_stock": true
       }
     ]'

# 価格範囲での検索
curl "http://localhost:8983/solr/mycore/select?q=price:[2000 TO 5000]&fl=id,title,price"

# 在庫ありの商品のみ
curl "http://localhost:8983/solr/mycore/select?q=in_stock:true&fl=id,title,price,in_stock"
```

## 🚀 高度な機能

### ファセット検索（集計機能）

```bash
# カテゴリ別の件数を取得
curl "http://localhost:8983/solr/mycore/select?q=*:*&rows=0&facet=true&facet.field=category" | jq '.facet_counts.facet_fields.category'

# 著者別の件数を取得
curl "http://localhost:8983/solr/mycore/select?q=*:*&rows=0&facet=true&facet.field=author"
```

### ハイライト機能

```bash
# 検索キーワードをハイライト表示
curl -G "http://localhost:8983/solr/mycore/select" \
     --data-urlencode "q=content:Apache" \
     --data-urlencode "hl=true" \
     --data-urlencode "hl.fl=content" \
     --data-urlencode "hl.simple.pre=<mark>" \
     --data-urlencode "hl.simple.post=</mark>"
```

### ソート機能

```bash
# 日付の降順（新しい順）
curl "http://localhost:8983/solr/mycore/select?q=*:*&sort=published_date%20desc"

# タイトルのアルファベット順
curl "http://localhost:8983/solr/mycore/select?q=*:*&sort=title%20asc"

# 複数条件でソート
curl "http://localhost:8983/solr/mycore/select?q=*:*&sort=category%20asc,published_date%20desc"
```

### ページング

```bash
# 最初の5件
curl "http://localhost:8983/solr/mycore/select?q=*:*&rows=5&start=0"

# 6件目から10件目
curl "http://localhost:8983/solr/mycore/select?q=*:*&rows=5&start=5"

# 検索結果の総件数確認
curl "http://localhost:8983/solr/mycore/select?q=*:*&rows=0" | jq '.response.numFound'
```

## 🔨 開発者向け情報

### 設定ファイルの場所

Solr の設定ファイルは以下の場所にあります：

```bash
# コンテナ内の設定確認
docker exec -it local-solr ls -la /opt/solr/server/solr/mycore/conf/

# スキーマ定義の確認
docker exec -it local-solr cat /opt/solr/server/solr/mycore/conf/managed-schema

# Solr設定の確認
docker exec -it local-solr cat /opt/solr/server/solr/mycore/conf/solrconfig.xml
```

### API エンドポイント一覧

| エンドポイント            | 用途         | 例                      |
| ------------------------- | ------------ | ----------------------- |
| `/solr/mycore/select`     | 検索         | `?q=Apache&fl=id,title` |
| `/solr/mycore/update`     | データ更新   | POST JSON データ        |
| `/solr/admin/cores`       | コア管理     | `?action=STATUS`        |
| `/solr/admin/info/system` | システム情報 | システム状態確認        |
| `/solr/mycore/schema`     | スキーマ管理 | フィールド定義確認      |

### スキーマレス機能

Solr 8.11 では動的フィールドがデフォルトで有効になっています：

```bash
# 新しいフィールドを自動で追加
curl -X POST "http://localhost:8983/solr/mycore/update?commit=true" \
     -H "Content-Type: application/json" \
     -d '[{
       "id": "test001",
       "new_field_string": "文字列フィールド",
       "new_field_int": 123,
       "new_field_date": "2023-08-24T12:00:00Z"
     }]'

# スキーマの確認
curl "http://localhost:8983/solr/mycore/schema/fields" | jq '.fields[] | select(.name | startswith("new_field"))'
```

### バージョン確認

```bash
# Solr と Lucene の詳細バージョン確認
curl "http://localhost:8983/solr/admin/info/system" | jq '.lucene'

# システム全体の情報確認
curl "http://localhost:8983/solr/admin/info/system" | jq '.system'

# Java バージョンの確認
curl "http://localhost:8983/solr/admin/info/system" | jq '.jvm.version'

# Docker イメージの確認
docker images | grep solr
```

### パフォーマンス監視

```bash
# インデックスのサイズ確認
curl "http://localhost:8983/solr/admin/cores?action=STATUS&core=mycore" | jq '.status.mycore.index'

# メモリ使用量確認
curl "http://localhost:8983/solr/admin/info/system" | jq '.system.committedVirtualMemorySize'

# JVMの状態確認
curl "http://localhost:8983/solr/admin/info/system" | jq '.jvm'
```

## 🛑 環境の停止・削除

### 環境停止

```bash
./scripts/stop.sh
```

### データを含めた完全削除

```bash
docker-compose down -v
docker system prune
```

## 🔍 トラブルシューティング

### 1. Solr に接続できない

```bash
# コンテナの状態を確認
docker-compose ps

# Solrログを確認
docker-compose logs solr
```

### 2. ポートが使用中エラー

```bash
# ポート使用状況を確認
lsof -i :8983

# 他のプロセスを停止するか、docker-compose.ymlでポートを変更
```

### 3. メモリ不足エラー

`docker-compose.yml`の`SOLR_HEAP`値を調整してください：

```yaml
environment:
  - SOLR_HEAP=1g # メモリを増やす
```

### 4. Solr 9.4 での起動エラー

初期設定では Solr 9.4 を使用していましたが、configset の問題で起動しない場合があります。現在の設定では安定した Solr 8.11-slim を使用しています。

### 5. 日本語検索でエラーが出る場合

日本語文字を URL エンコードする必要があります：

```bash
# 正常な検索方法
curl -G "http://localhost:8983/solr/mycore/select" --data-urlencode "q=category:技術書"
```

### 6. 環境の完全リセット

問題が解決しない場合は、環境を完全にリセットしてください：

```bash
docker-compose down -v
docker system prune -f
./scripts/setup.sh
```

## 📚 参考リンク

- [Apache Solr 公式ドキュメント](https://solr.apache.org/guide/)
- [Solr Docker Hub](https://hub.docker.com/_/solr)
- [Solr Reference Guide](https://solr.apache.org/guide/solr/latest/)

## 📝 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。
