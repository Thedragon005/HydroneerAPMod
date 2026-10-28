---Battle-related hooks
---@class ShopHooks
local DirtHooks = {}
local TableHelpers = require "Utils.TableHelpers"
GlobalOreDict = {
	OreIron = 0,
	OreGold = 0,
	OreCloutium = 0,
	OreCorestone = 0,
	OreScrap = 0,
	OreShard = 0
}


---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table
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