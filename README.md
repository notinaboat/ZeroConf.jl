# ZeroConf.jl

[DNS Service Discovery](https://en.wikipedia.org/wiki/Zero-configuration_networking#DNS-based_service_discovery) (DNS-SD, ZeroConf, Bonjour) interface for Julia.

On macOS (or BSD) this package uses the `dns-sd` tool (see `man dns-sd`). On Linux the [Avahi](https://www.avahi.org) tools are used instead (`apt-get install avahi-utils`).


```
dns_service_browse([type = "_http._tcp"]) -> Channel{DNSService}
```

Open a channel to browse for DNS Services of a certian `type`. Reading from channel yeilds pairs: `name => (host, port)`.

e.g.

```
julia> c = dns_service_browse()
julia> take!(c)
"AxisCamera" => ("axis-ptz.local.", 80)
```


```
register_dns_service(name, service_type, port)
```

Register a DNS Service.


```
unregister_dns_service(name)
```

Cancel a service registered by `register_dns_service`.

