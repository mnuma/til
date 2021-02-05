
- 公式Nginxと同じようにOpenrestyでもenvsubstによる設定ファイルテンプレートを用いるDockerfileとヘルパースクリプト
  - 指定したdefault.conf.templateの中身を置換し `/etc/nginx/conf.d/default.conf` に変換する仕組み

```Dockerfile
ARG OPENRESTY_IMAGE_TAG_BASE="1.19.3.1-2"
FROM openresty/openresty:${OPENRESTY_IMAGE_TAG_BASE}-alpine

RUN apk --no-cache add libintl && \
    apk --no-cache add --virtual .gettext gettext && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del .gettext

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGTERM

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;"]
```


```docker-entrypoint.sh
#!/bin/sh
set -e
set -x

readonly default_conf_template="/tmp/templates/default.conf.template"
readonly exclude_environment_variables="HOSTNAME|SHLVL|HOME|PATH|PWD"

if [ -e $default_conf_template ]; then
    defined_envs=$(env | grep -v -E "${exclude_environment_variables}" | cut -d= -f1 | awk '{ printf "${%s} ", $1 }')
    envsubst "$defined_envs" < ${default_conf_template} > /etc/nginx/conf.d/default.conf
fi

exec "$@"
```
