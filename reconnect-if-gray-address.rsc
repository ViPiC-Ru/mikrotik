# reconnecting when set a gray ipv4 address or update ipv4 firewall list

:local name;
:local value;
:local network 100.0.0.0;
:local netmask 255.0.0.0;
:local list "{firewall-list-for-internet-ip}";
:local IPv4 $"local-address";

/interface;
:set name [get $interface name];
:if ($network = ($IPv4 & $netmask)) do={
    # reconnecting this connection
    :delay 7s;
    :log info "$name: reconnecting gray ip address $IPv4";
    set $interface disabled=yes;
    set $interface disabled=no;
} else={
    /ip firewall address-list;
    # update ipv4 address in firewall list
    :foreach record in=[find where !disabled !dynamic comment=$name] do={
        :if ([get $record list] = $list) do={
            :if ([:len $IPv4] != 0) do={
                :if ([get $record address] != $IPv4) do={
                    :log info "change address $IPv4 in list $list";
                    set $record address=$IPv4;
                };
                :if ([get $record comment] != $name) do={
                    set $record comment=$name;
                };
                :set IPv4;
            } else={
                :set value [get $record address];
                :log info "remove address $value in list $list";
                remove $record;
            };
        };
    };
    # add ipv4 address in firewall list
    :if ([:len $IPv4] != 0) do={
        :log info "add address $IPv4 in list $list";
        add list=$list address=$IPv4 comment=$name;
        :set IPv4;
    };
};