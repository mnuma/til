
## 複数バージョンを使う時

goenvなどを使わなくても公式で複数バージョンの切り替えなどが可能

```
$ brew install go

$ go get golang.org/dl/go1.14.4
$ $GOPATH/bin/go1.14.4 download
$ ll $GOPATH/bin/
```

```zshrc
export GOPATH=$HOME/go/
export PATH=$PATH:$GOPATH/bin
alias go='$GOPATH/bin/go1.14.4'
```
