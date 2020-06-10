中間証明書のverifyを確認する時

```
openssl s_client -servername www.xxxx.jp -connect www.xxxx.jp:443 -showcerts </dev/null >c.pem                                                                   master ✭ ◼
openssl crl2pkcs7 -nocrl -certfile c.pem | openssl pkcs7 -print_certs -text -noout
```
