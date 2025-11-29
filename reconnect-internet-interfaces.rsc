# reconnect internet interfaces

:local interface;
:local list "internet";

/interface list member;
:foreach member in=[find] do={
    :if ([get $member list] = $list) do={
        :set interface [get $member interface];
        :log info "$interface: reconnecting...";
        /interface disable $interface;
        :delay 7s;
        /interface enable $interface;
    };
};