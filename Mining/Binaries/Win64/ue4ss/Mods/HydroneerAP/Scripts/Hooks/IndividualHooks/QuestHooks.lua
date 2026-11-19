---Battle-related hooks
---@class ShopHooks
local QuestHooks = {}
local TableHelpers = require "Utils.TableHelpers"
local StringHelpers = require "Utils.StringHelpers"
KingsQuestNPCList = {
	"BP_NPC_KingGuard01",
	"BP_NPC_KingGuard02",
	"BP_NPC_KingGuard03",
	"BP_NPC_KingGuard04",
	"BP_NPC_King"
}

---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table
local function S(v)
    local ok, r = pcall(function() return v:ToString() end)
    return ok and r or tostring(v)
end

local function FindSpecificNPC(targetName)
    local allNpcs = FindAllOf("BP_NPC_C")
    if not allNpcs then return nil end
    
    for _, npc in pairs(allNpcs) do
        if npc and npc:IsValid() then
            -- GetFullName() typically returns something like: "BP_NPC_C /Game/Maps/.../BP_NPC_KingGuard01_C_1"
            local fullName = npc:GetFullName()
            if fullName:match(targetName) then
                return npc
            end
        end
    end
    
    return nil
end

local function ClassName(obj)
    return obj:GetClass():GetFName():ToString()      -- e.g. "BP_UncutRuby_C"
end
local function GetNPCInfo(NPC)
		local note = NPC.RequestNote
        local task = NPC.Task
		return {
        class        = ClassName(NPC),
        outer        = NPC:GetOuter(),
		Name		 = NPC.Name,
		NPC_ID		 = NPC["NPC ID"],
		Location	 = NPC.Location,
		note		 = note or "",
		task		 = task or "",
    }
end
local function GetQuestInfo(quest)
	
	return {
        class        = ClassName(quest),
        outer        = quest:GetOuter(),
    }
end

local function CountQuest(key,NPC)
	if TableHelpers.Contains(KingsQuestNPCList, NPC) then
		GlobalQuestDict[key] = 1
	else
		GlobalQuestDict[key] = (GlobalQuestDict[key] or 0) + 1
	end
	print("GlobalQuestDict updated : "..key.." =>"..TableHelpers.Dump(GlobalQuestDict[key]))
end


--When a quest is completed but not reward claimed, it will linger and count again
function QuestHooks:Register(hookManager, dependencies)
    local logger = dependencies.logger
	--[[
	hookManager:Register(
        "/Game/Joe_Characters/BP/NPC/Requests/C_Task.C_Task_C:Complete",
        function(context, ...)
			self:CompleteQuest(context,...)
			--self.dumpProps(context, ...)
        end,
       "Quest - CompleteQuest"
    )
	hookManager:Register(
        "/Game/Joe_Characters/BP/NPC/BP_NPC.BP_NPC_C:DestroyRequestNote",
        function(context, ...)
			self:CompleteQuest(context,...)
			--self.dumpProps(context, ...)
        end,
       "Quest - CompleteQuest"
    )
	--]]
	hookManager:Register(
        "/Game/Joe_Characters/BP/NPC/BP_NPC.BP_NPC_C:ClearRequest", --ClearRequest
        function(context, ...)
			self:CompleteQuest(context,...)
        end,
       "Quest - CompleteQuest"
    )
    logger:info("Quest hooks registered")
	print("Quest hooks registered")
end

function QuestHooks:CompleteQuest(context,...)
	local NPC = context:get()
    if not (NPC and NPC:IsValid()) then return end
	local npcClass = NPC:GetFName():ToString()

	
	local NPC_Info = GetNPCInfo(NPC)
	print(NPC_Info.task:GetFullName())
	local taskClass = ClassName(NPC_Info.task)
	print(taskClass)
	print("Completed Quest! " .. NPC_Info.task:GetFullName())

	--local info = GetQuestInfo(quest)
	-- Turn the King's quest flags to true for AP if the quest giver is the guards OR the king
	if TableHelpers.Contains(KingsQuestNPCList, npcClass) then
		local shortnpc = npcClass:match("^BP_NPC_([^_]+)")    -- "KingGuard01" ...
        if not shortnpc then return end
		print("King's Quest done for ".. shortnpc)
		CountQuest(shortnpc,npcClass)
	else
	
		local short = taskClass:match("^C_Task_([^_]+)_")   -- "Farming","Crafting","Propecting"
		if not short then return end
		print("Quest done of type :" .. short)
		CountQuest(short,npcClass)
	end
	
	-- King's quest dropping request does not open the door !!!
	-- Maybe look into Unique requests to trigger the flag??
	--[[
	ExecuteWithDelay(1000, function()
		ExecuteInGameThread(function()
			print(npcClass)
			local controller = FindSpecificNPC(npcClass)
			print(controller:GetFullName())
			if controller and controller:IsValid() then
				--controller:DropItem()
				--controller:ClearRequest()
				--local test = controller:FindRequestNote()
				--print(test:GetFName())
				print("Dropping!")
			end
			
		end)
	end)
	--]]
end

return QuestHooks