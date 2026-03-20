# update ddns record

# SCHEDULER
# :global service "duckdns";
# :global mode "ipv4"; :global domain "xxx";
# :global token "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
# /system script run "update-ddns-record";
# :set service; :set mode; :set domain; :set token;

:global service;
:global domain;
:global token;
:global mode;

:local url;
:local IPv4;
:local IPv6;
:local query;

# get public ip addresses
/ip cloud;
:if ($mode = "dual" || $mode = "ipv4" ) do={ :set IPv4 [get "public-address"] };
:if ($mode = "dual" || $mode = "ipv6" ) do={ :set IPv6 [get "public-address-ipv6"] };
# generate url for update
:if ($service = "duckdns") do={
    :set query "domains=$domain&token=$token";
    :if ([:len $IPv4] != 0) do={ :set query "$query&ip=$IPv4" };
    :if ([:len $IPv6] != 0) do={ :set query "$query&ipv6=$IPv6" };
    :set url "https://www.duckdns.org/update?$query";
};
# update ddns record by url
/tool;
:if ([:len $url] != 0) do={
    :log info "update ddns record on $service for $domain";
    fetch url=$url output=none;
};