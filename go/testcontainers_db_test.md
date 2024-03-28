
Go言語でPostgreSQLコンテナ(testcontainers)を使用してデータベースのテストを行う方法について

## 必要なパッケージ

```go
import (
	"context"
	"database/sql"
	"fmt"
	"strconv"

	"github.com/tanimutomo/sqlfile"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)
```

## データベース構造体の定義
Database 構造体は、データベース接続とその設定情報を保持します。

```go
type Database struct {
	DB   *sql.DB
	Host string
	Port int
}
```

## データベース初期化関数

```go
const (
	dbUser     = "app_admin"
	dbPassword = "testpassword"
	dbName     = "testdb"
)

func InitializeDatabase(ctx context.Context) (*Database, error) {
	// PostgreSQLコンテナを起動する
	req := testcontainers.ContainerRequest{
		Image:        "postgres:15.3",
		ExposedPorts: []string{"5432/tcp"},
		Env: map[string]string{
			"POSTGRES_USER":     dbUser,
			"POSTGRES_PASSWORD": dbPassword,
			"POSTGRES_DB":       dbName,
		},
		WaitingFor: wait.ForListeningPort("5432/tcp"),
	}
	pgContainer, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to start postgres container: %v", err)
	}

	// コンテナのポートを取得する
	port, err := pgContainer.MappedPort(ctx, "5432")
	if err != nil {
		return nil, fmt.Errorf("failed to get port for postgres container: %v", err)
	}

	host, err := pgContainer.Host(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get host for postgres container: %v", err)
	}

	// データベースに接続する
	uri := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port.Port(), dbUser, dbPassword, dbName)
	db, err := sql.Open("postgres", uri)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %v", err)
	}

	// テーブル・ロールを追加する
	s := sqlfile.New()
	err = s.Files("test/resources/create_role.sql", "../../backend/sql/schema.sql")
	_, err = s.Exec(db)
	if err != nil {
		return nil, fmt.Errorf("failed to migrate database: %v", err)
	}

	portInt, err := strconv.Atoi(port.Port())
	if err != nil {
		return nil, fmt.Errorf("failed to convert from string to int: %v", err)
	}

	return &Database{
		DB:   db,
		Host: host,
		Port: portInt,
	}, nil
}
```

- コンテナの起動: testcontainers ライブラリを使用してPostgreSQLのコンテナを起動します。環境変数を設定してデータベースのユーザー、パスワード、名前を指定します。
- ポートとホストの取得: コンテナが起動した後、そのポートとホストを取得します。これらは後のステップでデータベースへの接続に使用されます。
- データベースへの接続: 取得したポートとホストを用いて、データベース接続文字列を作成し、データベースに接続します。
- テーブルとロールの作成: SQLファイルを読み込み、実行して、テストに必要なテーブルやロールをデータベースに作成します。
