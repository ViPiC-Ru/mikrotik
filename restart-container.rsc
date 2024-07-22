# restart container by netwatch

:local hostname $comment;

/container;
:foreach container in=[find] do={
    :if ([get $container hostname] = $hostname) do={
		stop $container;
		:while ([get $container status] != "stopped") do={
			:delay 1s;
		};
		start $container;
		:log info "restart container $hostname";
    };
};