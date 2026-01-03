local mod = get_mod("BuyUntilStatDistribution")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "bulk_purchase",
				type = "group",
				sub_widgets = {
					{
						setting_id = "enable_bulk_purchase",
						type = "checkbox",
						default_value = true,
						sub_widgets = {
							{
								setting_id = "bulk_quantity",
								type = "numeric",
								default_value = 5,
								range = { 1, 20 },
							},
						}
					},
				}
			},
		}
	}
}
