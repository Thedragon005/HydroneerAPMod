---Battle-related hooks
---@class ShopHooks
local ShopHooks = {}


---comment
---@param datatable UDataTable
---@param shop_data ShopData
---@param table_to_insert_data_inserted_in_datatable table
local function AddItemRowsInDataTable(datatable, shop_data, is_extra, table_to_insert_data_inserted_in_datatable)
    local base_struct = {
        ItemRowName_18_22FD2F5E42C1473FBA6AB9BF09E4890C  = FName("Consumable_LuminaPoint"),
        PriceOverride_6_7DE9A0224D826DBF8CF033AD6077A4EE = 666,
        LevelOverride_8_A53457704B4D0037ECA806A29C727EF4 = -1,
        Quantity_10_A62DFEDB41EF5DA12CE979AB3F742758     = 1,
    } ---@type FS_MerchantItemData

    local item_type = is_extra and "Extra Item" or "Item"
    local number_to_add = is_extra and Archipelago.options.extra_location_per_shop or Archipelago.options.location_per_shop

    for i = 1, number_to_add, 1 do
        local name = "Merchant (" .. shop_data.region .. "): " .. shop_data.name .. " - " .. item_type .. " " .. tostring(i)
        local scouted_location = Storage:Get("merchant_scouted")[name]
        if scouted_location.found then
            goto scout_found
        end

        datatable:AddRow(name, base_struct)
        table.insert(table_to_insert_data_inserted_in_datatable[datatable:GetFName():ToString()], 
            { ["name"] = name, ["classification"] = scouted_location.classification}
        )

        ::scout_found::
    end
end

---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table
function ShopHooks:Register(hookManager, dependencies)
    self.last_shop_visited = nil
    local logger = dependencies.logger

    local table_current_shop = {}

    -- Removing "Owned: x" in the row
    hookManager:Register(
        "/Mining/Content/WorldObj/Items/BuildItems/Machinery/BP_ParentDrill.",
        self:RemoveShopOwnedBox(),
        "Shop - Lock Items"
    )
    logger:info("Shop hooks registered")
end


return ShopHooks