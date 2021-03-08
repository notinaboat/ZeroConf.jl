function dns_service_browse(service_type)

    result = Channel{DNSService}(0)

    p = open(`avahi-browse --no-fail --parsable --resolve $service_type`)

    @async try
        while isopen(result) &&
              (process_running(p) || bytesavailable(p) > 0)

            l = readline(p)
            if !startswith(l, "=")
                continue
            end
            l = split(l, ";")
            if l[3] == "IPv6" && l[5] == service_type
                tag, net, ip, name, type, domain, target, address, port = l
                push!(result, name => (target, parse(Int16, port)))
            end
        end
    catch err
        if !isopen(result) &&
           err isa InvalideStateException &&
           err.state == closed 
            # Ignore push to closed Channel error.
        else
            @error err
        end
    finally
        close(result)
        kill(p)
    end

    return result
end


function register_dns_service(name, service_type, port)
    global dns_process
    dns_process[name] =
    open(`avahi-publish --no-fail --service $name _tinyrpc._tcp $port`)
end
