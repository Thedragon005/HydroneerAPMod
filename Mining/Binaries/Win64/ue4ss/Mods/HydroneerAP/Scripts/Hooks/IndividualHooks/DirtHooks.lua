---Battle-related hooks
---@class ShopHooks
local DirtHooks = {}
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

local function CountOre(key)
    GlobalOreDict[key] = (GlobalOreDict[key] or 0) + 1
    print(key.." : "..TableHelpers.Dump(GlobalOreDict[key]))
end

function DirtHooks:Register(hookManager, dependencies)
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
    logger:info("Dirt hooks registered")
	--print("Dirt hooks registered")
end

function DirtHooks:ReceiveBeginPlay(context)
    local chunk = context:get()
    if not IsValidObj(chunk) then return end

    local info = GetChunkInfo(chunk)

    -- Cut gems are counted in GrindGem. Skip them here so they are not counted
    -- twice, including when they spawn again on a save load.
    if info.class:match("^BP_Gem") then return end

    -- no owner = freshly spawned chunk
    if not IsValidObj(info.owner) then
        local short = info.class:match("^BP_([^_]+)_")    -- "Iron", "UncutRuby", ...
        if not short then return end

        print("New chunk! " .. chunk:GetFullName())
        CountOre(short)
    end
end

function DirtHooks:GrindGem(context, uncutGem)
    print("Hello")
	local ok, gem = pcall(function() return uncutGem:get() end)
    if not (ok and IsValidObj(gem)) then return end
    local kind = ClassName(gem):match("^BP_Uncut([^_]+)_")   -- "Ruby"
    print(ClassName(gem))
	print(kind)
	if not kind then return end

    print("Grinding " .. gem:GetFullName())
    CountOre("Gem" .. kind)                                   -- "GemRuby"
end

return DirtHooks