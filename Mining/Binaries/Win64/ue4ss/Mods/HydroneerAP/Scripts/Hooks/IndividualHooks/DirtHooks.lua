---Battle-related hooks
---@class ShopHooks
local DirtHooks = {}
local TableHelpers = require "Utils.TableHelpers"

---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table

local function hasPlayerCharacter()
    local pc = FindFirstOf("PlayerController")
    if not pc or not pc:IsValid() then return false end
    local pawn = pc.Pawn          -- property name in the engine's PlayerController
    return pawn ~= nil and pawn:IsValid()
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
    logger:info("Dirt hooks registered")
	print("Dirt hooks registered")
	print(hasPlayerCharacter())
end

local function GetChunkInfo(chunk)
	local DataTable = {
		class = chunk:GetClass():GetFName():ToString(),
		owner = chunk:GetOwner(),
		attachParent = chunk:GetAttachParentActor(),
		outer = chunk:GetOuter()
	}
	return DataTable
end


function DirtHooks:ReceiveBeginPlay(context)
    local chunk = context:get()
    local name = chunk:GetFullName()
	local ChunkInfo = GetChunkInfo(chunk)
	
	if ChunkInfo.owner:GetFullName() == nil then
		print("New chunk!")
		local startpos = string.find(ChunkInfo.class, "_",1,true)+1
		local endpos = string.find(ChunkInfo.class, "_",startpos+1,true) -1
		local ChunkShortName = string.sub(ChunkInfo.class, startpos , endpos)
		GlobalOreDict[ChunkShortName] = GlobalOreDict[ChunkShortName] + 1
		
		print(TableHelpers.Dump(GlobalOreDict))
	end
end


return DirtHooks