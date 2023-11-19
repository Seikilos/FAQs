Nomad on windows with WSL2 Linux containers
=============================
As of `nomad 1.6.3` nomad dev mode does not work on windows because docker must be set to windows containers.

Workaround is to run the nomad agent in the WSL2 Linux container, where docker is running.

* Assign a static IP to your windows (the identity of the server uses the IP). This is very important
  *   in elevated prompt:  `netsh interface ip add address "vEthernet (WSL)" 172.19.200.1 255.255.255.0`
 
On WSL2 Linux create a file called `~/nomad-agent.hcl` with
```hcl
client {
  enabled = true
  servers = ["172.19.200.1:4647"]
}
```
Start agent with `nomad agent -config=nomad-client.hcl -data-dir=/home/your_user/data_dir`

*Note: Probably have to sudo nomad and put the hcl file somewhere, where root can reach it*
