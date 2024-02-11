# backup system config

:local isFound;
:local value;
:local version;
:local architecture;

:local path "{path-for-backup-folder}";
:local isNeedPackage true;

:log info "backup system config";
# add device name to path
/system identity;
:set value [get name];
:set path "$path/$value";
# back startup config
/;
export file="$path/startup.rsc" show-sensitive;
# back system settings
/system backup;
save dont-encrypt=yes name="$path/system.backup";
# get system information
/system resource;
:set architecture [get architecture-name];
:set value [get version];
:set value [:pick $value 0 [:find $value " "]];
:set version $value;
# work with package file
:if ($isNeedPackage) do={
	# delete old package file
	/file;
	:set isFound false;
	:foreach file in=[find where name~"$path/" type="package"] do={
		:set value [get $file package-architecture];
		:if ([:pick $architecture 0 [:len $value]] = $value && [get $file package-version] = $version) do={
			:set isFound true;
		} else={
			remove [get $file name];
		};
	};
	# download new package file
	/tool;
	:if (!$isFound) do={
		fetch url="https://download.mikrotik.com/routeros/$version/routeros-$version-$architecture.npk" dst-path "$path";
	};
};