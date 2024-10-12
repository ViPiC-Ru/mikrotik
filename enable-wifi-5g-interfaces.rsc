# torgle wireless interfaces

:local filter "5g";
:local action "enable";

/interface/wifiwave2;
:log info "$action wireless $filter interfaces";
:foreach interface in=[find name~$filter] do={
	:if ($action = "disable") do={ disable $interface };
	:if ($action = "enable") do={ enable $interface };
};