### ビルド時のキャッシュについて

- docker-compose経由でのgo test実行してるが事前ビルドが都度走るのでオーバヘッドがかかる。

https://golang.org/pkg/cmd/go/#hdr-Build_and_test_caching

`GOCACHE`でキャッシュするディレクトリを指定して、volumeでマウントさせたら高速化した。
2回目移行15sほどの削減になった。

```
services:
  unittest:
    image: golang:1.13.5
    environment:
      - GOCACHE=/tmp/cache
    volumes:
      - ./:/go/app
      - ./.cache:/tmp/cache
    working_dir: /go/auth-api
    command: >
      time go test -race --cover -v -covermode=atomic -coverprofile=coverage.out ./...

 ```
