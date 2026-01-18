# reconnect internet interfaces

/system script run "init-global-values";

:global "LIST_IFACE_INTERNET";

:local interfaceName;
:local inetInterfaceList $"LIST_IFACE_INTERNET";

/interface list member;
:foreach member in=[find] do={
    /interface list member;
    :if ([get $member list] = $inetInterfaceList) do={
        :set interfaceName [get $member interface];
        # reconnecting this connection
        /interface;
        :log info "$interfaceName: reconnecting...";
        disable $interfaceName;
        :delay 7s;
        enable $interfaceName;
    };
};