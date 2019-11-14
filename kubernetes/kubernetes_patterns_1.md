## Red Hatが公開してるKubernetes Patternsを読んでみるメモ

大きく分けて以下

- Foundational Patterns 基本的なパターン
- Behavioral Patterns 動作パターン
- Structural Patterns 構造パターン
- Configuration Patterns 設定パターン
- Advanced Patterns 応用パターン


### Predictable Demands

`予測される需要`

色々なアプリケーションのリソース要件を満たす、データストレージなどを定義する時

- `persistentVolumeClaim` を使ったボリュームマウント
- `configMapKeyRef` を使ったconfig読み込み
- `ResourceQuota` を使ったリソース制限
- `PriorityClass` でリソース優先度を設定

til :)
