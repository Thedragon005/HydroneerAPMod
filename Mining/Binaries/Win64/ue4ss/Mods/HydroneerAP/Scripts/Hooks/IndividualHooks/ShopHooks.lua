---Battle-related hooks
---@class ShopHooks
local ShopHooks = {}
local TableHelpers 	= require "Utils.TableHelpers"

local SPAWN_STANDARD, SPAWN_STORE, SPAWN_PROXY = 0, 1, 2
local PrimCompClass = StaticFindObject("/Script/Engine.PrimitiveComponent")

local ECC_Pawn = 2
local PAWN_RESPONSE_BY_LOCKED = {
    [true]  = 0, -- ECR_Ignore
    [false] = 2, -- ECR_Block
}

---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table
local function ClassOf(o) return o:GetClass():GetFName():ToString() end

function ShopHooks:Register(hookManager, dependencies)
    self.last_shop_visited = nil
    local logger = dependencies.logger

    local table_current_shop = {}

    logger:info("Shop hooks registered")
end

function ShopHooks:ProcessShopItems()
    ExecuteInGameThread(function()
        local disabledItems = {}
        local enabledItems = {}

        for _, it in ipairs(FindAllOf("BP_ParentItem_C") or {}) do
            if it:IsValid() and not it:GetFullName():find("Default__", 1, true) then
                local st = it.SpawnType
                if st == SPAWN_STORE then
                    self:LockItem(it, disabledItems, enabledItems)
                end
            end
        end

        -- Display Disabled first, then Enabled last
        local output = {
            string.format("[ShopHooks] Disabled (%d):\n  %s",
                #disabledItems,
                #disabledItems > 0 and table.concat(disabledItems, "\n  ") or "None"),
            string.format("[ShopHooks] Enabled (%d):\n  %s",
                #enabledItems,
                #enabledItems > 0 and table.concat(enabledItems, "\n  ") or "None")
        }
        print(table.concat(output, "\n") .. "\n")
    end)
end

function ShopHooks:LockItem(item, disabledList, enabledList)
    if item and type(item.get) == "function" then
        item = item:get()
    end
    if not (item and item:IsValid()) then return end

    local class = ClassOf(item)
    local isLocked = not TableHelpers.Contains(UnlockedShopItemsList or {}, class)
    local pawnResponse = PAWN_RESPONSE_BY_LOCKED[isLocked]
    local itemLabel = string.format("%s | Class: %s", item:GetFName():ToString(), class)

    if isLocked then
        if disabledList then
            table.insert(disabledItems or disabledList, itemLabel)
        else
            print(string.format("[ShopHooks] Disabling item: %s\n", itemLabel))
        end
    else
        if enabledList then
            table.insert(enabledList, itemLabel)
        else
            print(string.format("[ShopHooks] Allowing item: %s\n", itemLabel))
        end
    end

    item:SetActorHiddenInGame(isLocked)
    item["PreventPickup?"] = isLocked

    -- Lazy-load PrimCompClass only if it wasn't ready at startup
    if not (PrimCompClass and PrimCompClass:IsValid()) then
        PrimCompClass = StaticFindObject("/Script/Engine.PrimitiveComponent")
    end

    local comps = item:K2_GetComponentsByClass(PrimCompClass)
    if not comps then return end

    for i = 1, #comps do
        local elem = comps[i]
        local comp = (elem and type(elem.get) == "function") and elem:get() or elem
        if comp and comp:IsValid() then
            comp:SetCollisionResponseToChannel(ECC_Pawn, pawnResponse)
        end
    end
end

return ShopHooks
