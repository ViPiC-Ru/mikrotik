# rotate ipsec peer address by netwatch

:local value;
:local address;

:if ($status = "down") do={
	/ip ipsec peer;
	:foreach peer in=[find] do={
		:if ([get $peer name] = $comment) do={
			:set address [get $peer address];
			:if ([:typeof [:find $address "/"]] != "nil") do={
				:set value [:tostr $address];
				:set value [:pick $value 0 [:find $value "/"]];
				:set address $value;
			};
			set $peer address=[get $peer comment];
			set $peer comment=$address;
			:log info "rotate ipsec peer $comment";
		};
	};
};