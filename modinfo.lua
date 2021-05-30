name =
[[Survivial Leaderboard]]
description =
[[v1.0
Shows how many days all current and previous players of the server have survived.
]]
author = "Lavax, Larethian"
version = "1.0"
priority = -1000
server_filter_tags = {"leaderboard", "survival ranking"}

forumthread = ""

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{
	{
        name = "RESET",
        label = "Reset on server restart",
        options =   {
                        {description = "yes", data = true},
                        {description = "no", data = false},
                    },
        default = false,
		hover = "Select to delete leaderboard on server restart",
    },
}