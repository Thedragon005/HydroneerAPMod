---Battle-related hooks
---@class ShopHooks
local VeggiesHooks = {}
local TableHelpers = require "Utils.TableHelpers"

---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table

local function ClassName(obj)
    return obj:GetClass():GetFName():ToString()      -- e.g. "BP_UncutRuby_C"
end

local function IsValidObj(obj)
    return obj ~= nil and obj:IsValid()
end

local function GetVegInfo(Veg)
    return {
        class        = ClassName(Veg),
        owner        = Veg:GetOwner(),
        attachParent = Veg:GetAttachParentActor(),
        outer        = Veg:GetOuter(),
    }
end

GlobalVeggiesDict = GlobalVeggiesDict or {}

local SCALEIN = "/Game/WorldObj/Items/Resources/Veg/BP_ParentVeg.BP_ParentVeg_C:ScaleIn"
local TRACKED = {
    BP_VegTomato_C   = "Tomato",
    BP_VegCarrot_C   = "Carrot",
    BP_VegCorn_C     = "Corn",
    BP_VegOnion_C    = "Onion",
    BP_VegBroccoli_C = "Broccoli",
    BP_VegBeetroot_C = "Beetroot",
}

local seen = {}

function VeggiesHooks:Register(hookManager, dependencies)
    local logger = dependencies.logger

    hookManager:Register(
        "/Game/WorldObj/Items/Resources/Veg/BP_ParentVeg.BP_ParentVeg_C:ScaleIn",
        function(context, ...)
            self:GrowVeggies(context)
			--self.dumpProps(context, ...)
        end,
        "Veggies - ReceiveBeginPlay"
    )
    logger:info("Veggies hooks registered")
	print("Veggies hooks registered")
end

function VeggiesHooks:GrowVeggies(context)

	local veg = context:get()
    if not (veg and veg:IsValid()) then return end

    local class = veg:GetClass():GetFName():ToString()
    local key = veg:GetFullName()
    print("[Veg ScaleIn] " .. class .. " | " .. key .. "\n")  -- remove once it works

    local label = TRACKED[class]
    if not label then return end        -- not one we count
    if seen[key] then return end        -- already counted this instance
    seen[key] = true

    GlobalVeggiesDict[label] = (GlobalVeggiesDict[label] or 0) + 1
    print(label .. " created by crop! Total: " .. GlobalVeggiesDict[label] .. "\n")
	print("GlobalVeggiesDict updated : "..label.." =>"..TableHelpers.Dump(GlobalVeggiesDict[label]))

end

return VeggiesHooks