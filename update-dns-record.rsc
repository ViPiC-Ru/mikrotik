# update dns record

/system script run "init-global-values";

:global "DOMAIN_DEFAULT";
:global "IFACE_SELF";

:local mac;
:local arp;
:local peer;
:local container;
:local value;
:local isFound;
:local interfaceName;
:local host;
:local domain;
:local type;
:local IPv4;
:local IPv6;
:local address;
:local linkNetwork fe80::;
:local linkMask ffc0::;
:local defDomain $"DOMAIN_DEFAULT";
:local selfInterface $"IFACE_SELF";
:local resolutions {{type="event"}};
:local ttl 00:03:00;

:if ([:len $user] = 0 && [:len $leaseServerName] = 0) do={
    :set resolutions {{type="self"}};
    /ip arp;
    :foreach arp in=[find where dynamic complete mac-address address interface !disabled] do={
        :set resolutions ($resolutions, {{type="arp";id=$arp}});
    };
    /ip ipsec active-peers;
    :foreach peer in=[find where dynamic-address responder id~"="] do={
        :set resolutions ($resolutions, {{type="ipsec";id=$peer}});
    };
    /interface wireguard peers;
    :foreach peer in=[find where comment !disabled] do={
        :set resolutions ($resolutions, {{type="wireguard";id=$peer}});
    };
    /system package;
    :foreach package in=[find where name="container" !disabled] do={
        /container;
        :foreach container in=[find where running] do={
            :set resolutions ($resolutions, {{type="container";id=$container}});
        };
    };
};
:foreach resolution in=$resolutions do={
    :set mac;
    :set IPv4;
    :set IPv6;
    :set host;
    :set interfaceName;
    :set domain $defDomain;
    # getting mac address
    :if ($resolution->"type" = "arp") do={
        /ip arp;
        :set arp ($resolution->"id");
        :set mac [get $arp mac-address];
    };
    :if ([:len $leaseActMAC] != 0) do={
        :set mac $leaseActMAC;
    };
    # getting interface name
    :if ($resolution->"type" = "arp") do={
        /ip arp;
        :set arp ($resolution->"id");
        :set interfaceName [get $arp interface];
    };
    :if ($resolution->"type" = "container") do={
        /container;
        :set container ($resolution->"id");
        :set interfaceName [get $container interface];
    };
    :if ($resolution->"type" = "self") do={
        :set interfaceName $selfInterface;
    };
    :if ([:len $leaseServerName] != 0) do={
        /ip dhcp-server;
        :foreach server in=[find where name=$leaseServerName !disabled] do={
            :set interfaceName [get $server interface];
        };
    };
    # getting ipv4 address
    :if ($resolution->"type" = "arp") do={
        /ip arp;
        :set arp ($resolution->"id");
        :set IPv4 [get $arp address];
    };
    :if ($resolution->"type" = "ipsec") do={
        /ip ipsec active-peers;
        :set peer ($resolution->"id");
        :set IPv4 [get $peer dynamic-address];
    };
    :if ($resolution->"type" = "wireguard") do={
        /interface wireguard peers;
        :set peer ($resolution->"id");
        :set value [:pick [get $peer allowed-address] 0];
        :set value [:pick $value 0 [:find $value "/"]];
        :set IPv4 $value;
    };
    :if ($resolution->"type" = "container") do={
        /interface veth;
        :foreach address in=[get $interfaceName address] do={
            :if ([:typeof $address] = "ip-prefix") do={
                :set value [:tostr $address];
                :set value [:pick $value 0 [:find $value "/"]];
                :set IPv4 $value;
            };
        };
    };
    :if ($resolution->"type" = "self") do={
        /ip address;
        :foreach address in=[find where !disabled !invalid] do={
            :if ([get $address interface] = $interfaceName) do={
                :set value [get $address address];
                :set value [:pick $value 0 [:find $value "/"]];
                :set IPv4 $value;
            };
        };
    };
    :if ([:len $leaseActIP] != 0) do={
        :set IPv4 $leaseActIP;
    };
    :if ([:len $"remote-address"] != 0) do={
        :set IPv4 $"remote-address";
    };
    # getting host domain
    /ip dhcp-server network;
    :foreach network in=[find where !disabled] do={
        :if ($IPv4 in [get $network address]) do={
            :set value [get $network domain];
            :if ([:len $value] != 0) do={
                :set domain $value;
            };
        };
    };
    :if ($resolution->"type" = "container") do={
        /container;
        :set container ($resolution->"id");
        :set value [get $container domain-name];
        :if ([:len $value] != 0) do={
            :set domain $value;
        };
    };
    # check disconnect event
    :if ([:len $leaseBound] != 0) do={
        :if ($leaseBound = 0) do={
            :set IPv4;
            :set mac;
        };
    };
    :if ([:len $"remote-address"] != 0) do={
        /ppp active;
        :set value $"remote-address";
        :foreach connection in=[find where address=$value] do={
            :set value;
        };
        :if ([:len $value] != 0) do={
            :set IPv4;
            :set mac;
        };
    };
    # getting host name
    :if ($resolution->"type" = "arp" && [:len $interfaceName] != 0 && [:len $mac] != 0) do={
        /ip dhcp-server;
        :foreach server in=[find where lease-script=[:jobname] !disabled] do={
            /ip dhcp-server;
            :if ([get $server interface] = $interfaceName) do={
                /ip dhcp-server lease;
                :foreach lease in=[find where address=$IPv4 mac-address=$mac server=$server !disabled] do={
                    :set value [get $lease host-name];
                    :if ([:len $value] != 0) do={
                        :set host "$value.$domain";
                    };
                    :set value [get $lease comment];
                    :if ([:len $value] != 0) do={
                        :set host "$value.$domain";
                    };
                };
            };
        };
    };
    :if ($resolution->"type" = "ipsec") do={
        /ip ipsec active-peers;
        :set peer ($resolution->"id");
        :set value [get $peer id];
        :set value [:pick $value ([:find $value "CN="] + 3) [:len $value]];
        :if ([:typeof [:find $value "."]] = "nil") do={
            :set value "$value.$domain";
        };
        :set host "$value";
    };
    :if ($resolution->"type" = "wireguard") do={
        /interface wireguard peers;
        :set peer ($resolution->"id");
        :set value [get $peer comment];
        :set host "$value.$domain";
    };

    :if ($resolution->"type" = "container") do={
        /container;
        :set container ($resolution->"id");
        :set value [get $container hostname];
        :set host "$value.$domain";
    };
    :if ($resolution->"type" = "self") do={
        /system identity;
        :set value [get name];
        :set host "$value.$domain";
    };
    :if ([:len $user] != 0) do={
        :set host "$user.$domain";
    };
    :if ([:len $"lease-hostname"] != 0) do={
        :set value $"lease-hostname";
        :set host "$value.$domain";
    };
    # getting ipv6 address
    :if ([:len $interfaceName] != 0 && [:len $mac] != 0) do={
        /ipv6 neighbor;
        :foreach neighbor in=[find where mac-address=$mac interface=$interfaceName address status!=failed] do={
            :set value [get $neighbor address];
            :if (($value & $linkMask) != $linkNetwork) do={
                :set IPv6 $value;
            };
        };
    };
    :if ($resolution->"type" = "container") do={
        /interface veth;
        :foreach address in=[get $interfaceName address] do={
            :if ([:typeof $address] = "ip6-prefix") do={
                :set value [get $interfaceName comment];
                :set value [:pick $value ([:find $value " - "] + 3) [:len $value]];
                :set IPv6 $value;
            };
        };
    };
    :if ($resolution->"type" = "self") do={
        /ipv6 address;
        :foreach address in=[find where global !disabled !invalid] do={
            :if ([get $address interface] = $interfaceName) do={
                :set value [get $address address];
                :set value [:pick $value 0 [:find $value "/"]];
                :set IPv6 $value;
            };
        };
    };
    # processing dns records
    :if ([:len $host] != 0) do={
        /ip dns static;
        # existing dns records
        :foreach record in=[find where name=$host] do={
            :set address;
            :set isFound false;
            :set type [get $record type];
            :if ($type = "A") do={ :set address $IPv4 };
            :if ($type = "AAAA") do={ :set address $IPv6 };
            :if ([:len $address] != 0) do={
                :if ([get $record address] != $address) do={
                    :log info "change $type dns record for $host";
                    set $record address=$address;
                };
                :if ([get $record ttl] != $ttl) do={
                    set $record ttl=$ttl;
                };
                :if ($type = "A") do={ :set IPv4 };
                :if ($type = "AAAA") do={ :set IPv6 };
                :set isFound true;
            };
            :if (!$isFound) do={
                :log info "remove $type dns record for $host";
                remove $record;
            };
        };
        # new dns records
        :foreach type in={"A";"AAAA"} do={
            :if ($type = "A") do={ :set address $IPv4 };
            :if ($type = "AAAA") do={ :set address $IPv6 };
            :if ([:len $address] != 0) do={
                :log info "add $type dns record for $host";
                add type=$type address=$address name=$host ttl=$ttl;
            };
        };
    };
};