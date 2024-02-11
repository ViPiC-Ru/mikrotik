# update or reboot

/system package update;
check-for-updates;
:if ([get status] = "New version is available") do={
	:log info "update system";
	install;
} else={
	:log info "reboot system";
	/system;
	reboot;
};