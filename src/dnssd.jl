function dns_service_browse(service_type)

    result = Channel{DNSService}(0)
    
    # Browse for service instances and display output in zone file format.
    p = open(`dns-sd -Z $service_type`)

    @async try
        while isopen(result) &&
              (process_running(p) || bytesavailable(p) > 0)

            l = readline(p)
            if isempty(l) || startswith(l, ";")
                continue
            end
            l = split(l)
            if l[2] == "SRV"
                # e.g.: FooBar._tinyrpc._tcp  SRV 0 0 2020 foobar.local. ; ..."
                service, SRV, priority, weight, port, target = l
                name = split(service, ".")[1]
                push!(result, name => (target, parse(Int16, port)))
            end
        end
    catch err
        if !isopen(result) &&
           err isa InvalideStateException &&
           err.state == closed 
            # Ignore push to closed Channel error.
        else
            exception=(err, catch_backtrace())
            @error "Error reading `dns-sd -Z` output." exception
        end
    finally
        close(result)
        kill(p)
    end

    return result
end


function register_dns_service(name, service_type, port)
    global dns_process
    dns_process[(name, service_type)] =
    open(`dns-sd -R $name $service_type local $port`)
    nothing
end
