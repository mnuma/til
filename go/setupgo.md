
# 複数バージョンを使う時

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
