# restart container by netwatch

/container;
:foreach hostname in=[:toarray $comment] do={
	:foreach container in=[find] do={
		:if ([get $container hostname] = $hostname) do={
			stop $container;
			:while (![get $container stopped]) do={
				:delay 1s;
			};
			start $container;
			:log info "restart container $hostname";
		};
	};
};