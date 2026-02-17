# detect fail2ban action and ban address

/system script run "init-global-values";

:global "LIST_ADDR_BAN";
:global "TIME_BAN";

:local value;
:local before;
:local after;
:local delim;
:local index;
:local last;
:local address;
:local addresses;
:local startTime;
:local banTime $"TIME_BAN";
:local banAddressList $"LIST_ADDR_BAN";

# detect action for syslog
/system clock;
:set startTime ([get date] + [get time] - $banTime);
/log;
:foreach log in=[find where topics~"system" message~"login failure"] do={
    :if ([:totime [get $log time]] >= $startTime) do={
        # get fragment between before and after
        :set value [get $log message]; :set before "from "; :set after " ";
        :set value [:pick $value ([:find $value $before] + [:len $before]) [:len $value]];
        :set value [:pick $value 0 [:find $value $after]];
        # add ip to list
        :set address [:toip $value];
        :if ([:typeof $address] = "nil") do={ :set address [:toip6 $value] };
        :if ([:typeof $address] != "nil") do={ :set addresses ($addresses, $address) };
    };
};
# detect action for container
/system package;
:foreach package in=[find where name="container" !disabled] do={
    /system clock;
    :set startTime ([get date] + [get time] - [:totime [get gmt-offset]] - $banTime);
    /container log;
    :foreach log in=[find where container="apache" message~"auth_basic:error"] do={
        :if ([:totime [get $log time]] >= $startTime) do={
            # get fragment between before and after
            :set value [get $log message]; :set before "[remote "; :set after "]";
            :set value [:pick $value ([:find $value $before] + [:len $before]) [:len $value]];
            :set value [:pick $value 0 [:find $value $after]];
            # discard last fragment split by delim
            :set delim ":"; :set index -1;
            :do { :set last $index; :set index [:find $value $delim $last] } while=([:typeof $index] != "nil");
            :if ($last != -1) do={ :set value [:pick $value 0 $last] };
            # add ip to list
            :set address [:toip $value];
            :if ([:typeof $address] = "nil") do={ :set address [:toip6 $value] };
            :if ([:typeof $address] != "nil") do={ :set addresses ($addresses, $address) };
        };
    };
    :foreach log in=[find where container="syncthing" message~"Bad credentials"] do={
        :if ([:totime [get $log time]] >= $startTime) do={
            # get fragment between before and after
            :set value [get $log message]; :set before "address="; :set after " ";
            :set value [:pick $value ([:find $value $before] + [:len $before]) [:len $value]];
            :set value [:pick $value 0 [:find $value $after]];
            # add ip to list
            :set address [:toip $value];
            :if ([:typeof $address] = "nil") do={ :set address [:toip6 $value] };
            :if ([:typeof $address] != "nil") do={ :set addresses ($addresses, $address) };
        };
    };
};
# ban address
:foreach address in=$addresses do={
    :if ([:typeof $address] = "ip") do={
        /ip firewall address-list;
        :set value [:tostr $address];
        # check exist record
        :foreach record in=[find where !disabled list=$banAddressList] do={
            :if ([get $record address] = $value) do={ :set address };
        };
        # add new record
        :if ([:len $address] != 0) do={
            :log info "add address $address in list $banAddressList";
            add list=$banAddressList address=$address timeout=$banTime;
        };
    };
    :if ([:typeof $address] = "ip6") do={
        /ipv6 firewall address-list;
        :set value ([:tostr $address] . "/128");
        # check exist record
        :foreach record in=[find where !disabled list=$banAddressList] do={
            :if ([get $record address] = $value) do={ :set address };
        };
        # add new record
        :if ([:len $address] != 0) do={
            :log info "add address $address in list $banAddressList";
            add list=$banAddressList address=$address timeout=$banTime;
        };
    };
};