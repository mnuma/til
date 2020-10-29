- Make taskで実行確認する

```
run-for-prd:
	@read -p "Are you sure? [y/N]: " ans && [ $${ans:-N} = y ]
  ...
```
