# wake on lan

:local MAC;
:local value;
:local prefix "wol";
:local interface "{interface-for-broadcast}";

# check ipv6 firewall rule
/ipv6 firewall nat;
:foreach rule in=[find where log-prefix=$prefix packets] do={
	:set value [get $rule comment];
	:set value [:pick $value ([:find $value " for "] + 5) [:find $value " on "]];
	:set MAC $value;
	reset-counters $rule;
	:log info "wol on $interface for $MAC by ipv6";
	/tool wol interface=$interface mac=$MAC;
};

# check ipv4 firewall rule
/ip firewall nat;
:foreach rule in=[find where log-prefix=$prefix packets] do={
	:set value [get $rule comment];
	:set value [:pick $value ([:find $value " for "] + 5) [:find $value " on "]];
	:set MAC $value;
	reset-counters $rule;
	:log info "wol on $interface for $MAC by ipv4";
	/tool wol interface=$interface mac=$MAC;
};