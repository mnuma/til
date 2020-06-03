### imagePullPolicy

- Always: 常にコンテナイメージをPullする
- IfNotPresent: 既にコンテナイメージがあればPullを実行しない
- Never: Pullを実行しない。ローカルにコンテナイメージがあることを期待する


```
spec:
      containers:
      - image: nginx
        name: nginx
        imagePullPolicy: Always
```
