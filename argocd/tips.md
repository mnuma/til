# port-forward debug


```
$ k get svc -n argocd
NAME                    TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                      AGE
argocd                  NodePort    x.x.x.x    <none>        80:31510/TCP,443:30636/TCP   1d

$ k port-forward svc/argocd -n argocd 8080:443

$ curl http://localhost:8080/
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Argo CD</title>
    
    
$ argocd login localhost:8080

$ argocd app get hogehoge
```
