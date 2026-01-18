# wake on lan

/system script run "init-global-values";

:global "IFACE_WOL";

:local mac;
:local value;
:local prefix "wol";
:local interfaceName $"IFACE_WOL";

# check ipv6 firewall rule
/ipv6 firewall nat;
:foreach rule in=[find where log-prefix=$prefix packets] do={
    :set value [get $rule comment];
    :set value [:pick $value ([:find $value " for "] + 5) [:find $value " on "]];
    :set mac $value;
    reset-counters $rule;
    :log info "wol on $interfaceName for $mac by ipv6";
    /tool wol interface=$interfaceName mac=$mac;
};

# check ipv4 firewall rule
/ip firewall nat;
:foreach rule in=[find where log-prefix=$prefix packets] do={
    :set value [get $rule comment];
    :set value [:pick $value ([:find $value " for "] + 5) [:find $value " on "]];
    :set mac $value;
    reset-counters $rule;
    :log info "wol on $interfaceName for $mac by ipv4";
    /tool wol interface=$interfaceName mac=$mac;
};