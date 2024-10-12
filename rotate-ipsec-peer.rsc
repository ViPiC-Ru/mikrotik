# rotate ipsec peer address by netwatch

:local value;
:local currentAddress;
:local nextAddress;
:local newComment "";

:if ($status = "down") do={
	/ip ipsec peer;
	:foreach peer in=[find] do={
		:if ([get $peer name] = $comment) do={
			# getting current address
			:set currentAddress [get $peer address];
			:if ([:typeof [:find $currentAddress "/"]] != "nil") do={
				:set value [:tostr $currentAddress];
				:set value [:pick $value 0 [:find $value "/"]];
				:set currentAddress $value;
			};
			# getting next address and build new comment
			:foreach value in=[:toarray [get $peer comment]] do={
				:if ([:typeof $nextAddress] != "nothing") do={
					:set newComment ($newComment . $value . ", ");
				} else={ :set nextAddress $value };
			};
			:set newComment ($newComment . $currentAddress);
			# setting pear address and comment
			set $peer address=$nextAddress comment=$newComment;
			:log info "rotate ipsec peer $comment by $nextAddress";
		};
	};
};