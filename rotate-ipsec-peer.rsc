# rotate ipsec peer address by netwatch

:local address;
:local name $comment;

/ip ipsec peer;
:foreach peer in=[find] do={
    :if ([get $peer name] = $name) do={
		:set address [get $peer comment];
		set $peer comment=[get $peer address];
		set $peer address=$address;
		:log info "rotate ipsec peer $name";
    };
};