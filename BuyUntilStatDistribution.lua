local mod = get_mod("BuyUntilStatDistribution")
local ItemUtils = require("scripts/utilities/items")
local MasterItems = require("scripts/backend/master_items")
local WeaponStats = require("scripts/utilities/weapon_stats")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIWidget = require("scripts/managers/ui/ui_widget")
local SliderPassTemplates = require("scripts/ui/pass_templates/slider_pass_templates")

local STAT_THRESHOLD = 380
local NUMBER_OF_STATS = 5
local views = "scripts/ui/views/"


mod._just_purchased = false
mod._user_stats = {}

mod._selected_weapon = ""


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
    local total = 0
    for stat, data in pairs(mod._user_stats) do
        total = total + data.value
    end
    return total
end

local _init = function()
    mod._user_stats = {}
end

mod:hook_safe("CreditsGoodsVendorView", "_on_purchase_complete", function(self, items)
    --does the same _close_result_overlay (thus making that function redundant)
    if self._result_overlay then
        self._result_overlay = nil

        self:_remove_element("result_overlay")
    end
    Managers.event:trigger("event_vendor_view_purchased_item")
    if total_stats() > STAT_THRESHOLD then 
        mod:echo(mod.ERROR_MSG)
        return
    end
    
    for _, item_data in ipairs(items) do 
        local uuid = item_data.uuid
        local item = MasterItems.get_item_instance(item_data, uuid)
        if item then
            local itemID = item.gear_id
            local weapon_stats = WeaponStats:new(item)

            local start_expertise = ItemUtils.total_stats_value(item)

            local max_preview_expertise = ItemUtils.max_expertise_level() - start_expertise

            local comparing_stats = weapon_stats:get_comparing_stats() 
            local max_stats = ItemUtils.preview_stats_change(item, max_preview_expertise, comparing_stats)

            local isValidWeapon = true
            for i, stat in ipairs(comparing_stats) do
                local user_stat = mod._user_stats[stat.display_name]
                if user_stat then --this should be checking for user_stat and that there is a user_stat.value
                    local purchased_max_value = max_stats[stat.display_name]
                    if purchased_max_value then
                        local max_value = purchased_max_value.value or purchased_max_value.fraction
                        if max_value < user_stat.value then
                            isValidWeapon = false
                            break
                        end
                    end
                end
            end
            if isValidWeapon then
                ItemUtils.set_item_id_as_favorite(itemID, true)
                mod:notify("WEAPON FOUND WITH REQUESTED STAT PROFILE")
            end
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
        --THIS SHOULDNT BE HERE -> set to true IF THE WEAPON IS TO BE FAVOURITED OTHERWISE FALSE
        mod._just_purchased = true
    end
end)

mod:hook_safe("CreditsGoodsVendorView", "_preview_item", function(self, item)
    --if the length of weapon_stats.base_stats == NUMBER_OF_STATS then continue else cancel
    mod._selected_weapon = item.weapon_template
    local weapon_stats = WeaponTemplates[mod._selected_weapon]
    _init()
    local slider_val = 1
    for _, stat_data in pairs(weapon_stats.base_stats) do
        mod._user_stats[stat_data.display_name] = {slider = "slider_"..slider_val, value = 0}
        slider_val = slider_val+1
    end

    for stat, data in pairs(mod._user_stats) do
        local slider = self._widgets_by_name[data.slider]

        if slider then
            local content = slider.content
            content.slider_value = data.value
            content.value_text = mod:localize(stat) .. ": " .. tostring(data.value)
        end
    end
end)

mod:hook_safe("CreditsGoodsVendorView", "update", function(self)
    if next(mod._user_stats) == nil then return end 

    for stat, data in pairs(mod._user_stats) do
        local slider = self._widgets_by_name[data.slider]

        if slider then
            local content = slider.content
            local raw_val = content.min + content.slider_value*(content.max - content.min)
            local stepped_value = math.floor(raw_val+0.5)

            if stepped_value ~= data.value then
                content.value_text = mod:localize(stat) .. ": " .. tostring(stepped_value)
                data.value = stepped_value
            end
        end
    end
end)

local append_to_vendor_view_defs = function(defs)
    if not defs then return end
    defs.grid_settings = defs.grid_settings or {}
    defs.scenegraph_definition = defs.scenegraph_definition or {}
    defs.widget_definitions = defs.widget_definitions or {}

    local x_offset = (defs.grid_settings.grid_spacing and defs.grid_settings.grid_spacing[1] * 2.5) or 25
    local y_offset = (defs.grid_settings.title_height or 50) + 50

    for i = 1, NUMBER_OF_STATS do
        local key = "slider_"..i
        defs.scenegraph_definition[key] = {
            vertical_alignment = "left",
            parent = "canvas",
            horizontal_alignment = "center",
            size = {510, 30},
            position = {x_offset, y_offset, 3}
        }
        y_offset = y_offset+50

        defs.widget_definitions[key] = UIWidget.create_definition(SliderPassTemplates.value_slider(520, 30, 270, true, false), key)

        local widget_def = defs.widget_definitions[key]
        if widget_def then
            local content = widget_def.content
            content.slider_value = 0
            content.max = 80
            content.min = 0
        end
    end
end

mod:hook_require(views.."credits_goods_vendor_view/credits_goods_vendor_view_definitions", append_to_vendor_view_defs)
_init()
