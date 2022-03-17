Git
---------------

Show all proxy settings
==================
` git config --global --get-regexp http.*`

Configure proxy for single resources
==================
Edit ~/.gitconfig

```
[http]
[http "https://github.com"]
	proxy = http://your_proxy:your_port
	sslVerify = false
```
