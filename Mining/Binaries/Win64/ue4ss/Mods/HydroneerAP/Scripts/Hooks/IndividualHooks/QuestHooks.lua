---Battle-related hooks
---@class ShopHooks
local QuestHooks = {}
local TableHelpers = require "Utils.TableHelpers"

---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table

local function ClassName(obj)
    return obj:GetClass():GetFName():ToString()      -- e.g. "BP_UncutRuby_C"
end

local function GetQuestInfo(chunk)
    return {
        class        = ClassName(chunk),
        outer        = chunk:GetOuter(),
    }
end

local function CountQuest(key)
    GlobalQuestDict[key] = (GlobalQuestDict[key] or 0) + 1
    print(key.." : "..TableHelpers.Dump(GlobalQuestDict[key]))
end


--King's quest still count towards this, make an exclusion for them
function QuestHooks:Register(hookManager, dependencies)
    local logger = dependencies.logger

	hookManager:Register(
        "/Game/Joe_Characters/BP/NPC/Requests/C_Task.C_Task_C:Complete",
        function(context, ...)
			self:CompleteQuest(context)
			--self.dumpProps(context, ...)
        end,
        "Quest - CompleteQuest"
    )

    logger:info("Quest hooks registered")
	print("Quest hooks registered")
end

function QuestHooks:CompleteQuest(context)
    
	local chunk = context:get()
    print("Completed Quest! " .. chunk:GetFullName())

    local info = GetQuestInfo(chunk)
	print(info.class)
	local short = info.class:match("^C_Task_([^_]+)_")    -- "Iron", "UncutRuby", ...
        if not short then return end

        print("Quest type :" .. short)
        CountQuest(short)
end

return QuestHooks