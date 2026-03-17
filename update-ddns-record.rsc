# update ddns record

/system script run "init-global-values";

:global "NAME_DDNS_SERVICE";
:global "TOKEN_DDNS_ACCOUNT";
:global "DOMAIN_DDNS_RECORD";
:global "MODE_DDNS_UPDATE";

:local url;
:local IPv4;
:local IPv6;
:local query;
:local service $"NAME_DDNS_SERVICE";
:local token $"TOKEN_DDNS_ACCOUNT";
:local domain $"DOMAIN_DDNS_RECORD";
:local mode $"MODE_DDNS_UPDATE";

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