Vagrant
===========

To download plugins or ISOs behind proxy. If not anonymous: first use Squid to setup a virtual machine, then set:

For Plugins
-----------

```ps1
set $Env:http_proxy=http://host:port
set $Env:https_proxy=https://host:port
vagrant plugin install vagrant-proxyconf
```

For ISOs

```ps1
set $Env:VAGRANT_HTTP_PROXY=%http_proxy%
set $Env:VAGRANT_HTTPS_PROXY=%https_proxy%
set $Env:VAGRANT_NO_PROXY="127.0.0.1"
vagrant up ...

```
