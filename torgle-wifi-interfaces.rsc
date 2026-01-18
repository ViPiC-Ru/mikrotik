# torgle wireless access point interfaces

# SCHEDULER
# :global action "disable"; :global filter "5g";
# /system script run "torgle-wifi-interfaces";
# :set action; :set filter;

:global filter;
:global action;

/interface wifiwave2;
:log info "$action wireless $filter interfaces";
:foreach interface in=[find name~$filter configuration.mode=ap] do={
    :if ($action = "disable") do={ disable $interface };
    :if ($action = "enable") do={ enable $interface };
};