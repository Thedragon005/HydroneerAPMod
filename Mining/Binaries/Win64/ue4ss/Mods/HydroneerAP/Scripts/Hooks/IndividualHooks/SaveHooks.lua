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
	OreShard = 0
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
    local tmp = path .. ".tmp"

    -- write_file throws on failure, so pcall it
    local ok, err = pcall(json.write_file, tmp, { ores = GlobalOreDict })
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

    print("Saved ore counts to " .. path .. "\n")
end

function SaveHooks:LoadGame(controller)
    local ok, data = pcall(json.read_file, savePath(controller))
    if not ok then
        print("Load failed (bad JSON?): " .. tostring(data) .. "\n")
        data = nil
	end

    -- read_file returns nil when the file doesn't exist yet
    for k in pairs(GlobalOreDict) do
        GlobalOreDict[k] = (data and data.ores and tonumber(data.ores[k])) or 0
    end
end

return SaveHooks