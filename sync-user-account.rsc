# synchronization user accounts in different modules

:local login;
:local account;

/system package;
:foreach package in=[find where name="user-manager" !disabled] do={
    # get user account
    /user-manager user;
    :foreach user in=[find] do={
        :set login [get $user name];
        :set account [get $user];
        # sync for smb users
        /ip smb users;
        :foreach user in=[find] do={
            :if ([get $user name] = $login) do={
                :if ([get $user password] != $account->"password") do={
                    :log info "sync smb user $login password from user manager";
                    set $user password=($account->"password");
                };
                :if ([get $user disabled] != $account->"disabled") do={
                    :log info "sync smb user $login disabled from user manager";
                    set $user disabled=($account->"disabled");
                };
            };
        };
    };
};