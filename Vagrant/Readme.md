Vagrant
===========

To download plugins or ISOs behind proxy. If not anonymous: first use Squid to setup a virtual machine, then set:

For Plugins
-----------

```ps1
# Powershell
$Env:http_proxy=http://host:port
$Env:https_proxy=https://host:port
# If proxy is http for https, remember to change the URL to http
vagrant plugin install vagrant-proxyconf
```

For Virtual Machines
-------------
Configure the network interface, on which squid is available


````vagrant
myvm.vm.network "private_network", ip: "192.168.59.99" # Bringing vm into the same network where proxy is reachable	

# This configures the vm itself (works good for linux)
myvm.proxy.http     = "http://192.168.56.99:3128"
myvm.proxy.https    = "http://192.168.56.99:3128"
myvm.proxy.no_proxy = "localhost,127.0.0.1"

```
		


