# update internet information

/system script run "init-global-values";

:global "IFACE_SELF";
:global "LIST_ADDR_SELF";
:global "LIST_ADDR_INTERNET";
:global "LIST_IFACE_INTERNET";
:global "ENABLE_CGNAT_RECONNECT";

:local IPv6;
:local IPv4;
:local address;
:local value;
:local addressList;
:local interfaceName;
:local cgnatNetwork 100.64.0.0;
:local cgnatNetmask 255.192.0.0;
:local inetInterfaceList $"LIST_IFACE_INTERNET";
:local inetAddressList $"LIST_ADDR_INTERNET";
:local selfInterface $"IFACE_SELF";
:local selfAddressList $"LIST_ADDR_SELF";
:local isNeedReconnect $"ENABLE_CGNAT_RECONNECT";
:local resolutions {{type="event"}};

:if ([:len $interface] = 0) do={
    :set resolutions {{type="self"}};
    /interface list member;
    :foreach member in=[find] do={
        :if ([get $member list] = $inetInterfaceList) do={
            :set value [get $member interface];
            :set resolutions ($resolutions, {{type="internet";name=$value}});
        };
    };
};
:if ($isNeedReconnect && [:len $interface] != 0 && [:len $"local-address"] != 0) do={
    :set IPv4 $"local-address";
    :if ($cgnatNetwork = ($IPv4 & $cgnatNetmask)) do={
        /interface;
        :set interfaceName [get $interface name];
        # reconnecting this connection
        :log info "$interfaceName: reconnecting gray ip address $IPv4";
        disable $interfaceName;
        :delay 7s;
        enable $interfaceName;
        :set resolutions;
    };
};
:delay 2s;
:foreach resolution in=$resolutions do={
    :set IPv4;
    :set IPv6;
    :set interfaceName;
    # getting interface name
    :if ($resolution->"type" = "internet") do={
        :set interfaceName ($resolution->"name");
    };
    :if ($resolution->"type" = "self") do={
        :set interfaceName $selfInterface;
    };
    :if ([:len $interface] != 0) do={
        /interface;
        :set interfaceName [get $interface name];
    };
    # getting address list
    :set addressList $inetAddressList;
    :if ($resolution->"type" = "self") do={
        :set addressList $selfAddressList;
    };
    # getting ipv4 address
    :if ($resolution->"type" = "internet" || $resolution->"type" = "self") do={
        /ip address;
        :foreach address in=[find where !disabled !invalid] do={
            :if ([get $address interface] = $interfaceName) do={
                :set value [get $address address];
                :set value [:pick $value 0 [:find $value "/"]];
                :set IPv4 $value;
            };
        };
    };
    :if ([:len $"local-address"] != 0) do={
        :set IPv4 $"local-address";
    };
    # getting ipv6 address
    /ipv6 address;
    :foreach address in=[find where global !disabled !invalid] do={
        :if ([get $address interface] = $interfaceName) do={
            :set value [get $address address];
            :set value [:pick $value 0 [:find $value "/"]];
            :set IPv6 $value;
        };
    };
    # processing ipv4 firewall list
    /ip firewall address-list;
    :set address $IPv4;
    :foreach record in=[find where !disabled !dynamic comment=$interfaceName] do={
        :if ([get $record list] = $addressList) do={
            :if ([:len $address] != 0) do={
                :if ([get $record address] != $address) do={
                    :log info "change address $address in list $addressList";
                    set $record address=$address;
                };
                :if ([get $record comment] != $interfaceName) do={
                    set $record comment=$interfaceName;
                };
                :set address;
            } else={
                :set value [get $record address];
                :log info "remove address $value in list $addressList";
                remove $record;
            };
        };
    };
    :if ([:len $address] != 0) do={
        :log info "add address $address in list $addressList";
        add list=$addressList address=$address comment=$interfaceName;
    };
    # processing ipv6 firewall list
    /ipv6 firewall address-list;
    :set address $IPv6;
    :if ([:len $address] != 0) do={ :set address "$address/128" };
    :foreach record in=[find where !disabled !dynamic comment=$interfaceName] do={
        :if ([get $record list] = $addressList) do={
            :if ([:len $address] != 0) do={
                :if ([get $record address] != $address) do={
                    :log info "change address $address in list $addressList";
                    set $record address=$address;
                };
                :if ([get $record comment] != $interfaceName) do={
                    set $record comment=$interfaceName;
                };
                :set address;
            } else={
                :set value [get $record address];
                :log info "remove address $value in list $addressList";
                remove $record;
            };
        };
    };
    :if ([:len $address] != 0) do={
        :log info "add address $address in list $addressList";
        add list=$addressList address=$address comment=$interfaceName;
    };
    # setting ipv6 dns address for all interface
    /ipv6 nd;
    :set address $IPv6;
    :if ($resolution->"type" = "self" && [:len $address] != 0) do={
        :foreach discovery in=[find where !disabled] do={
            :if ([get $discovery dns] != $address) do={
                :set value [get $discovery interface];
                :log info "change discovery dns address $address for $value";
                set $discovery dns=$address;
            };
        };
    };
};