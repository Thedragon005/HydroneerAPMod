---Battle-related hooks
---@class ShopHooks
local ShopHooks = {}
local TableHelpers 	= require "Utils.TableHelpers"

local SPAWN_STANDARD, SPAWN_STORE, SPAWN_PROXY = 0, 1, 2
local PrimCompClass = StaticFindObject("/Script/Engine.PrimitiveComponent")

local ECollisionChannel = {
    ECC_WorldStatic          = 0,
    ECC_WorldDynamic         = 1,
    ECC_Pawn                 = 2,
    ECC_Visibility           = 3,
    ECC_Camera               = 4,
    ECC_PhysicsBody          = 5,
    ECC_Vehicle              = 6,
    ECC_Destructible         = 7,

    ECC_EngineTraceChannel1  = 8,
    ECC_EngineTraceChannel2  = 9,
    ECC_EngineTraceChannel3  = 10,
    ECC_EngineTraceChannel4  = 11,
    ECC_EngineTraceChannel5  = 12,
    ECC_EngineTraceChannel6  = 13,

    ECC_GameTraceChannel1    = 14,
    ECC_GameTraceChannel2    = 15,
    ECC_GameTraceChannel3    = 16, -- Hydroneer shop detection
    ECC_GameTraceChannel4    = 17, -- Hydroneer shop detection
    ECC_GameTraceChannel5    = 18, -- Hydroneer Other actors collision
    ECC_GameTraceChannel6    = 19,
    ECC_GameTraceChannel7    = 20,
    ECC_GameTraceChannel8    = 21,
    ECC_GameTraceChannel9    = 22,
    ECC_GameTraceChannel10   = 23,
    ECC_GameTraceChannel11   = 24,
    ECC_GameTraceChannel12   = 25,
    ECC_GameTraceChannel13   = 26,
    ECC_GameTraceChannel14   = 27,
    ECC_GameTraceChannel15   = 28,
    ECC_GameTraceChannel16   = 29,
    ECC_GameTraceChannel17   = 30,
    ECC_GameTraceChannel18   = 31,

    ECC_OverlapAll_Deprecated = 32,
    ECC_MAX                   = 33,
}

local PAWN_RESPONSE_BY_LOCKED = {
    [true]  = 0, -- ECR_Ignore
    [false] = 2, -- ECR_Block
}

---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table
local function ClassOf(o) return o:GetClass():GetFName():ToString() end

function ShopHooks:Register(hookManager, dependencies)
    local logger = dependencies.logger

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
            comp:SetCollisionResponseToChannel(ECollisionChannel.ECC_Pawn, pawnResponse)
            comp:SetCollisionResponseToChannel(ECollisionChannel.ECC_Vehicle, pawnResponse)
            comp:SetCollisionResponseToChannel(ECollisionChannel.ECC_GameTraceChannel5, pawnResponse)
        end
    end
end

return ShopHooks
