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

local function GetChunkInfo(chunk)
    return {
        class        = ClassName(chunk),
        owner        = chunk:GetOwner(),
        attachParent = chunk:GetAttachParentActor(),
        outer        = chunk:GetOuter(),
    }
end

local function CountVeggies(key)
    GlobalVeggiesDict[key] = (GlobalVeggiesDict[key] or 0) + 1
    print("GlobalVeggiesDict updated : "..key.." =>"..TableHelpers.Dump(GlobalVeggiesDict[key]))
end

function VeggiesHooks:Register(hookManager, dependencies)
    local logger = dependencies.logger

    hookManager:Register(
        "/Game/WorldObj/Items/Resources/BP_ParentRawResource.BP_ParentRawResource_C:ReceiveBeginPlay",
        function(context, ...)
            self:ReceiveBeginPlay(context)
			--self.dumpProps(context, ...)
        end,
        "Dirt - ReceiveBeginPlay"
    )
	hookManager:Register(
        "/Game/WorldObj/Items/BuildItems/BP_GrindingWheel.BP_GrindingWheel_C:GrindGem",
        function(context, UncutGem)
			self:GrindGem(context, UncutGem)
		end,
        "GrindingWheel - GrindGem"
    )
	hookManager:Register(
        "/Game/WorldObj/Items/BuildItems/Conveyors/BP_HookGemPolisher.BP_HookGemPolisher_C:SpawnGem",
        function(context, OldUncut)
			self:GrindGem(context, OldUncut)
		end,
        "HookGemPolisher - GrindGem"
    )
    logger:info("Dirt hooks registered")
	--print("Dirt hooks registered")
end

function VeggiesHooks:ReceiveBeginPlay(context)
    local chunk = context:get()
    if not IsValidObj(chunk) then return end

    local info = GetChunkInfo(chunk)

    -- Prevent uncut gems from being counted, we need to grind them to count
	if info.class:match("^BP_Uncut") then return end

    -- no owner = freshly spawned chunk
    if not IsValidObj(info.owner) then
        local short = info.class:match("^BP_([^_]+)_")    -- "Iron", "UncutRuby", ...
        if not short then return end

        print("New chunk! " .. chunk:GetFullName())
        CountOre(short)
    end
end

function VeggiesHooks:GrindGem(context, gemParam)
    local ok, gem = pcall(function() return gemParam:get() end)
    if not (ok and IsValidObj(gem)) then return end

    -- wheel:    instance "BP_UncutRuby_C_2147482345"
    -- polisher: class    "BP_GemEmerald_C"
    local name = gem:GetFName():ToString()
    local kind = name:match("^BP_Uncut([^_]+)_C") or name:match("^BP_Gem([^_]+)_C")
    if not kind then
        print("GrindGem: unexpected gem " .. name)
        return
    end

    CountOre("Gem" .. kind)    -- "GemEmerald"
end

return VeggiesHooks