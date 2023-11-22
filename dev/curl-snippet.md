curlでBearer認証付き API を叩きたいときに zsh 向け snippet

```
# apicli v1.0.0
# e.g. apicli GET /hoge
# e.g. apicli POST /hoge
# e.g. apicli GET /hoge | jq
# e.g. apicli GET /hoge -i (with Options... -i -v -s)
# ! ACCESS_TOKEN=は適宜書き換えてください

export LOCAL_DEV_ACCESS_TOKEN=
function apicli() {
  local HTTP_METHOD="$1"
  local API_ENDPOINT="$2"
  local OPT="$3"
 
  # POSTである場合はPOST_DATAをセットする
  local POST_DATA='{"hoge":"a","fuga":"1","fugo":"test","piyo":"test","csv":"column-1,column-2,column-3,column-4\r\nTEST-1,,user-1,1\r\nTEST-2,,user-2,2\r\n"}'

  if [ -z "$API_ENDPOINT" ] || [ -z "$HTTP_METHOD" ]; then
    echo "Usage: api_client <HTTP_METHOD> <API_ENDPOINT>"
    return 1
  fi

  local CURL_COMMAND="curl -w '\n%{url_effective}\n%{http_code}\n'"

  case "$HTTP_METHOD" in
    GET)
      CURL_COMMAND+=" -X GET"
      ;;
    POST)
      CURL_COMMAND+=" -X POST -H 'content-type: application/json' -d '$POST_DATA'"
      ;;
    PATCH)
      CURL_COMMAND+=" -X PATCH -H 'content-type: application/json' -d '$POST_DATA'"
      ;;
		DELETE)
		  CURL_COMMAND+=" -X DELETE"
		  ;;
    *)
      echo "Invalid HTTP_METHOD: $HTTP_METHOD"
      return 1
      ;;
  esac


  CURL_COMMAND+=" -m 1 'http://localhost:8080$API_ENDPOINT' $OPT -H 'accept: application/json, text/plain, */*' -H 'authorization: Bearer $LOCAL_DEV_ACCESS_TOKEN'"
  eval "$CURL_COMMAND"
}
```
