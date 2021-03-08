"""
# ZeroConf.jl

[DNS Service Discovery](https://en.wikipedia.org/wiki/Zero-configuration_networking#DNS-based_service_discovery)
(DNS-SD, ZeroConf, Bonjour) interface for Julia.

On macOS (or BSD) this package uses the `dns-sd` tool (see `man dns-sd`).
On Linux the [Avahi](https://www.avahi.org) tools are used instead
(`apt-get install avahi-utils`).


"""
module ZeroConf

export dns_service_browse, register_dns_service, unregister_dns_service


"""
name => (host, port)
"""
const DNSService = Pair{String, Tuple{String, Int16}}


"""
    dns_service_browse([type = "_http._tcp"]) -> Channel{DNSService}

Open a channel to browse for DNS Services of a certian `type`.
Reading from channel yeilds pairs: `name => (host, port)`.

e.g.

    julia> c = dns_service_browse()
    julia> take!(c)
    "AxisCamera" => ("axis-ptz.local.", 80)
"""
dns_service_browse() = dns_service_browse("_http._tcp")


"""
    register_dns_service(name, service_type, port)

Register a DNS Service.
"""
register_dns_service(name, service_type, port)


dns_process = Dict{String,Base.Process}()

"""
    unregister_dns_service(name)

Cancel a service registered by `register_dns_service`.
"""
function unregister_dns_service(name)
    global dns_process
    kill(dns_process[name])
end


const dnssd_is_installed = Sys.which("dns-sd") != nothing
const avahi_is_installed = Sys.which("avahi-publish") != nothing

@static if dnssd_is_installed
    include("dnssd.jl")
elseif avahi_is_installed
    include("avahi.jl")
else
    @error """
        Can't find `dns-sd` or `avahi-publish`.
        Try `apt-get install avahi-utils`?
        """
end


readme() = join([
    Docs.doc(@__MODULE__),
    Docs.doc(dns_service_browse),
    Docs.doc(register_dns_service),
    Docs.doc(unregister_dns_service)
   ], "\n\n")


end # module
