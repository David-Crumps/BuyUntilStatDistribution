local mod = get_mod("BuyUntilStatDistribution")
local WeaponNames = mod:io_dofile("BuyUntilStatDistribution/weapon_names")

return {
	mod_name = {
		en = "Buy Until Stat Distribution",
	},
	mod_description = {
		en = "Select stats and receive a message when one with the required stats has been purchased",
	},
	group_select = {
		en = "Select stat distributions",
	},
	stat_1 = {
		en = "Weapon stat 1 (Damage)",
	},
	stat_2 = {
		en = "Weapon stat 2",
	},
	stat_3 = {
		en = "Weapon stat 3",
	},
	stat_4 = {
		en = "Weapon stat 4",
	},
	stat_5 = {
		en = "Weapon stat 5",
	},
	test_1 = {
		en = "Test 1"
	},
	test_2 = {
		en = "Test 2"
	},
	weapon_family = {
		en = "Weapon Family"
	},
	loc_stats_display_ap_stat = {
		en = "Penetration"
	},
	loc_stats_display_defense_stat = {
		en = "Defences"
	},
	loc_stats_display_damage_stat = {
		en = "Damage"
	},
	loc_stats_display_first_target_stat = {
		en = "First Target"
	},
	loc_stats_display_mobility_stat = {
		en = "Mobility"
	},
	loc_stats_display_finesse_stat = {
		en = "Finesse"
	},
	loc_stats_display_crit_stat = {
		en = "Critical Bonus"
	}
}
