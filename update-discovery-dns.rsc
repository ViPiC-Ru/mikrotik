# config ipv6 discovery dns and update ipv6 firewall list

:local IPv6;
:local value;
:local prefix 128;
:local list "{firewall-list-for-internet-ip}";
:local name "{internet-connection-name}";

:delay 2s;
/ipv6 address;
# getting global external ipv6 address
:foreach address in=[find where global !disabled !invalid] do={
	:if ([get $address interface] = $name) do={
		:set value [get $address address];
		:set value [:pick $value 0 [:find $value "/"]];
		:set IPv6 $value;
	};
};
# setting ipv6 dns address for all interface
:if ([:len $IPv6] != 0) do={
	/ipv6 nd;
	:foreach discovery in=[find where !disabled] do={
		:if ([get $discovery dns] != $IPv6) do={
			:set value [get $discovery interface];
			:log info "change discovery dns address $IPv6 for $value";
			set $discovery dns=$IPv6;
		};
	};
};
# setting ipv6 address in firewall list
:if ([:len $IPv6] != 0) do={
	/ipv6 firewall address-list;
	# update ipv6 address in firewall list
	:foreach record in=[find where !disabled !dynamic] do={
		:if ([get $record list] = $list) do={
			:if ([:len $IPv6] != 0) do={
				:set value "$IPv6/$prefix";
				:if ([get $record address] != $value) do={
					:log info "change address $IPv6 in list $list";
					set $record address=$value;
				};
				:if ([get $record comment] != $name) do={
					set $record comment=$name;
				};
				:set IPv6;
			} else={
				:set value [get $record address];
				:log info "remove address $value in list $list";
				remove $record;
			};
		};
	};
	# add ipv6 address in firewall list
	:if ([:len $IPv6] != 0) do={
		:set value "$IPv6/$prefix";
		:log info "add address $IPv6 in list $list";
		add list=$list address=$value comment=$name;
		:set IPv6;
	};
};