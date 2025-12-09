local mod = get_mod("BuyUntilStatDistribution")
local ItemUtils = require("scripts/utilities/items")
local MasterItems = require("scripts/backend/master_items")

local MasterData = require("scripts/backend/master_data")
local CraftingUtil = require("scripts/backend/crafting")


local STAT_THRESHOLD = 380

mod._stat_1 = 0
mod._stat_2 = 0
mod._stat_3 = 0
mod._stat_4 = 0
mod._stat_5 = 0
mod._just_purchased = false

mod.stats_exceed = false
mod.INFO_MSG = "INFO: Stats fall within acceptable range"
mod.ERROR_MSG = "ERROR: total stat distribution exceeds threshold of " .. STAT_THRESHOLD .. "!"

local function _character_save_data()
	local local_player_id = 1
	local player_manager = Managers.player
	local player = player_manager and player_manager:local_player(local_player_id)
	local character_id = player and player:character_id()
	local save_manager = Managers.save
	local character_data = character_id and save_manager and save_manager:character_data(character_id)

	return character_data
end

local function total_stats()
    return mod._stat_1 + mod._stat_2 + mod._stat_3 + mod._stat_4 + mod._stat_5
end


local stat_check = function(force_startup)
    local total = total_stats()
    if (total > STAT_THRESHOLD) then
        if force_startup or not mod.stats_exceed then
            mod:notify(mod.ERROR_MSG)
            mod.stats_exceed = true
        end
    elseif (total <= STAT_THRESHOLD) and mod.stats_exceed then
        mod:notify(mod.INFO_MSG)
        mod.stats_exceed = false
    end
end

local _init = function()
    mod._stat_1 = mod:get("stat_1")
    mod._stat_2 = mod:get("stat_2")
    mod._stat_3 = mod:get("stat_3")
    mod._stat_4 = mod:get("stat_4")
    mod._stat_5 = mod:get("stat_5")
end

function mod.on_setting_changed(setting_id)
    _init()
    stat_check(false)
end

mod:hook_safe("CreditsGoodsVendorView", "_on_purchase_complete", function(self, items)
    --has the same _close_result_overlay (thus making that function redundant)
    
    if self._result_overlay then
        self._result_overlay = nil

        self:_remove_element("result_overlay")
    end
    Managers.event:trigger("event_vendor_view_purchased_item")
    

    for _, item_data in ipairs(items) do 
        local uuid = item_data.uuid
        local item = MasterItems.get_item_instance(item_data, uuid)

        if item then
            local itemID = item.gear_id
            --ItemUtils.set_item_id_as_favorite(itemID, true)

            --[[
            mod:echo("-------------------------------------------")
            for i = 1, 5 do
                local stat = item.gear.masterDataInstance.overrides
                mod:echo("-------------------------------------------")
                for subKey, subValue in pairs(stat) do
                    mod:echo(tostring(subKey) .. "=" .. tostring(subValue))
                end
            end
            --]]
            mod:echo("--------------------------------------------------------------------")
        end

    end   
end)

mod:hook(ItemUtils, "set_item_id_as_favorite", function(func, item_gear_id, state)
    --If the item is being favourited after being purchased, do not play the sound 
    if mod._just_purchased then
        mod._just_purchased = false -- reset flag
        local character_data = _character_save_data()

        if not character_data then
            return
        end

        if not character_data.favorite_items then
        character_data.favorite_items = {}
        end

        local favorite_items = character_data.favorite_items
        favorite_items[item_gear_id] = state
        Managers.save:queue_save()
    else --otherwise play the sound
        func(item_gear_id, state)
    end
end)

mod:hook_safe(Managers.event, "trigger", function(self, event_name, ...)
    if event_name == "event_vendor_view_purchased_item" then
        mod._just_purchased = true
    end
end)

--activates when switching between melee and ranged tabs
mod:hook_safe("CreditsGoodsVendorView", "cb_switch_tab", function()
    mod:notify("cb_switch_tab")
end)

--activates on pressing an entry in brunts armoury
mod:hook_safe("CreditsGoodsVendorView", "cb_on_grid_entry_left_pressed", function()
    --mod:notify("cb_on_grid_entry_left_pressed")
end)

--activates on increasing weapon stats at hadron
mod:hook_safe(CraftingUtil, "add_weapon_expertise", function()
    mod:notify("add_weapon_expertise")
end)

_init()
stat_check(true)
