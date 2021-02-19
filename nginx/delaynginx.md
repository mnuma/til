## delayするnginx(openresty)を検証したいとき

See:
https://ubuntu.com/blog/avoiding-dropped-connections-in-nginx-containers-with-stopsignal-sigquit

```default.conf
server {
    listen       80;
    server_name  localhost;

    location / {
        proxy_pass   http://httpbin.org/delay/10;
    }
```


```Dockerfile
ARG OPENRESTY_IMAGE_TAG_BASE="1.19.3.1-2"
FROM openresty/openresty:${OPENRESTY_IMAGE_TAG_BASE}-alpine

STOPSIGNAL SIGTERM
COPY default.conf /etc/nginx/conf.d/default.conf
CMD ["/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;"]
```

```
docker build -f Dockerfile -t delay-nginx --no-cache .
docker run --rm -p 80:80 delay-nginx

curl http://localhost
```
