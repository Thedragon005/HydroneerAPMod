---Save-related hooks
---@class SaveHooks
local SaveHooks = {}
local DirtHooks     = require "Hooks.IndividualHooks.DirtHooks"
local TableHelpers 	= require "Utils.TableHelpers"
local json 			= require "Utils.json"

local SAVE_DIR = "../../Content/Paks/LogicMods/HydroneerRandomizer_data/"

GlobalOreDict = {
	OreIron = 0,
	OreGold = 0,
	OreCloutium = 0,
	OreCorestone = 0,
	OreScrap = 0,
	OreShard = 0,
	GemSaphire = 0,
	GemRuby = 0,
	GemEmerald = 0,
	GemDiamond = 0,
	GemOnyx = 0
}

GlobalQuestDict = {
	Farming = 0,
	Prospecting = 0,
	Crafting = 0,
	KingGuard01 = false,
	KingGuard02 = false,
	KingGuard03 = false,
	KingGuard04 = false,
	King = false
}

GlobalVeggiesDict = {
	Tomato = 0,
	Carrot = 0,
	Corn = 0,
	Onion = 0, 
	Broccoli = 0,
	Beetroot = 0,
}

UnlockedShopItemsList = {
	"BP_PipeIntakeT1_C",
	"BP_PipeElbowT1_C",
	"BP_PipeStraightT1_C"
}

---Register all save hooks
---@param hookManager HookManager
---@param dependencies table
local function slotKey() return CurrentSlot or "default" end

local function savePath(controller)
    local key = tostring(slotKey(controller)):gsub("[^%w%-_]", "_")
    return SAVE_DIR .. "save_" .. key .. ".json"
end



function SaveHooks:Register(hookManager, dependencies)
    local logger = dependencies.logger
	hookManager:Register(
        "/Game/BP_GameController.BP_GameController_C:ActorPreSave",
        --BndEvt__SaveButton_K2Node_ComponentBoundEvent_1_OnButtonClickedEvent__DelegateSignature
		function(context, ...)
            self:SaveGame(context)
			print("ActorPreSave")
			--self.dumpProps(context, ...)
        end,
        "Save - ActorPreSave"
    )
	
	hookManager:Register(
    "/Game/UI/MainMenu/UI_Menu_SaveManager.UI_Menu_SaveManager_C:SaveSelected",
    --BndEvt__...
    function(context, save)
        local ok, s = pcall(function() return save:get():ToString() end)
        if ok and s and s ~= "" then
            CurrentSlot = s
            print("Slot: " .. s .. "\n")
        end
        --self.dumpProps(context, ...)
    end,
    "Save - SaveSelected"
	)
	
	logger:info("Save hooks registered")
	--print("Save hooks registered")
end

function SaveHooks:SaveGame(context)
	local controller = context:get()
    local path = savePath(controller)
    path = path:gsub(" ", "_")
	local tmp = path .. ".tmp"

    -- write_file throws on failure, so pcall it
    local ok, err = pcall(json.write_file, tmp, { ores = GlobalOreDict, quests = GlobalQuestDict, veggies = GlobalVeggiesDict})
    if not ok then
        print("Save failed: " .. tostring(err) .. "\n")
        return
    end

    -- Windows' rename won't overwrite, so remove the old file first
    os.remove(path)
    local renamed, rerr = os.rename(tmp, path)
    if not renamed then
        print("Save rename failed: " .. tostring(rerr) .. "\n")
        return
    end

    print("Saved location counts to " .. path .. "\n")
end

function SaveHooks:LoadGame()
    -- Directly utilizing the absolute path you specified
    -- Step up twice from Binaries\Win64 to reach the root "Mining" folder
	local path = "..\\..\\Content\\Paks\\LogicMods\\HydroneerRandomizer_data\\save_" .. slotKey() .. ".json"
	path = path:gsub(" ", "_")
	print("Resolved Path: " .. path)
	local ok, data = pcall(json.read_file, path)
	if not ok then
        print("Load failed (bad JSON?): " .. tostring(data) .. "\n")
        data = nil
	end

    -- read_file returns nil when the file doesn't exist yet
    for k in pairs(GlobalOreDict) do
        GlobalOreDict[k] = (data and data.ores and tonumber(data.ores[k])) or 0
    end
	for k in pairs(GlobalQuestDict) do
        GlobalQuestDict[k] = (data and data.quests and tonumber(data.quests[k])) or 0
    end
	for k in pairs(GlobalVeggiesDict) do
		GlobalVeggiesDict[k] = (data and data.veggies and tonumber(data.veggies[k])) or 0
	end
	print("Loaded location counts from " .. path .. "\n")
	---[[
	print("Ores:"..TableHelpers.Dump(GlobalOreDict))
	print("Quests:"..TableHelpers.Dump(GlobalQuestDict))
	print("Veggies:"..TableHelpers.Dump(GlobalVeggiesDict))
	--]]
end

return SaveHooks