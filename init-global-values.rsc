# initialize global variables for all scripts

:global "ENABLE_AUTO_UPDATE" true;

:global "ENABLE_BACKUP_PACKAGE" true;
:global "ENABLE_BACKUP_PATH_IDENTITY" true;
:global "PATH_BACKUP" "usb1/home.local/MikroTik/Config";

:global "DOMAIN_DEFAULT" "home.local";
:global "IFACE_SELF" "vlan-local";
:global "IFACE_WOL" "vlan-local";

:global "LIST_IFACE_INTERNET" "internet";
:global "LIST_ADDR_INTERNET" "external-self";
:global "LIST_ADDR_SELF" "local-self";

:global "LIST_ADDR_BAN" "fail2ban-banned";
:global "TIME_BAN" 01:00:00;

:global "ENABLE_CGNAT_RECONNECT" true;