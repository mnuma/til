## aws-sdk-goのExponential Backoffの仕組みを調べた

SQSのメッセージレシーブを行う時に、connection reset by peerというエラーが出て、リクエスト出来ないことがあったのでaws-sdk-goを調べた。

```
RequestError: send request failed
caused by: Post https://sqs.ap-northeast-1.amazonaws.com/:  ... read: connection reset by peer
```

- aws-sdkにはRetryerという仕組みがありエラー時のリトライとして、Exponential Backoffを実装している。
https://github.com/aws/aws-sdk-go/blob/master/aws/request/retryer.go

- リトライされるケースはこの辺り、aws固有のエラーやconnection refusedされたパターンが含まれる
https://github.com/aws/aws-sdk-go/blob/master/aws/request/retryer.go#L166-L224

- read: connection resetのパターンも対象になるようだった
https://github.com/aws/aws-sdk-go/blob/master/aws/request/connection_reset_error.go#L8


- `WithMaxRetries` を使うとリトライ回数を設定出来る
https://docs.aws.amazon.com/sdk-for-go/api/aws/#Config.WithMaxRetries


```diff
- aws.NewConfig().WithRegion(region)
+ aws.NewConfig().WithRegion(region).WithMaxRetries(5))
```

- デフォルトだとDefaultRetryerがNewされるよう
https://github.com/aws/aws-sdk-go/blob/master/aws/client/client.go#L65-L70
https://github.com/aws/aws-sdk-go/blob/master/aws/client/default_retryer.go

- デフォルトの設定はこれら
https://github.com/aws/aws-sdk-go/blob/master/aws/client/default_retryer.go#L38-L53


```
DefaultRetryerMaxNumRetries = 3
```

- DefaultRetryerMaxNumRetriesは3なので、3回Exponential Backoffでリトライされる。

- リトライ間隔は指数関数的に増加するので、ベースの間隔をお30msとした場合、3回だと以下のような間隔と予想される。

```
1:30ms, 2:900ms, 3:27000ms(27s)
```

- 実際はJitterが入るので誤差がありえると思われる


til :)
