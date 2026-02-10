# update or reboot

/system script run "init-global-values";

:global "ENABLE_AUTO_UPDATE";
:local isAllowUpdate $"ENABLE_AUTO_UPDATE";

/system package update;
check-for-updates;
:if ($isAllowUpdate && [get installed-version] != [get latest-version]) do={
    :log info "update system";
    install;
} else={
    :log info "reboot system";
    /system;
    reboot;
};