# update or reboot

/system package update;
check-for-updates;
:if ([get installed-version] != [get latest-version]) do={
    :log info "update system";
    install;
} else={
    :log info "reboot system";
    /system;
    reboot;
};