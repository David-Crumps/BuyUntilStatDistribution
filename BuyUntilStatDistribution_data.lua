local mod = get_mod("BuyUntilStatDistribution")
local stat_range = {0, 80}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "group_select",
				type = "group",
				sub_widgets = {
					{
						setting_id = "stat_1",
						type = "numeric",
						default_value = 0,
						range = stat_range,
					},
					{
						setting_id = "stat_2",
						type = "numeric",
						default_value = 0,
						range = stat_range,
					},
					{
						setting_id = "stat_3",
						type = "numeric",
						default_value = 0,
						range = stat_range,
					},
					{
						setting_id = "stat_4",
						type = "numeric",
						default_value = 0,
						range = stat_range,
					},
					{
						setting_id = "stat_5",
						type = "numeric",
						default_value = 0,
						range = stat_range,
					},
				}
			},
		}
	}
}
