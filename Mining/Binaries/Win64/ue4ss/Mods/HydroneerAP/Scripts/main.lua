-- HydroneerAP mod
-- Created by UE4SS Lua Debugger
Logger     = require "Logger"
Hooks      = require "Hooks.index"
--Data       = require "Data"
--Debug      = require "Archipelago.Debug"
--Storage    = require "Storage.index" ---@type Storage
--Inventory  = require "Game.Inventory"
--Capacities = require "Game.Capacities"
--Characters = require "Game.Characters"
--Quests     = require "Game.Quests"
--Save       = require "Game.Save"
--ClientBP   = require "Game.ClientBP"
--Battle     = require "Game.Battle"
--CONSTANTS  = require "Constants.index"
Utils      = require "Utils.index"
--Commands   = require "Commands"


--Wait for main menu ????????????? Mod is failing at first now


print("[HydroneerAP] Mod loaded!")
Logger:initialize()   -- sets logFile so Logger doesn't fall back to Debug.print

local function RegisterHooks()
	print("[HydroneerAP - Hooks] - Loading completed, registering hooks\n")
	local ok, err = pcall(function() Hooks:Register() end)
	if not ok then
		print("[HydroneerAP - Hooks] - Hooks:Register failed: " .. tostring(err) .. "\n")
	end
end
local function UnregisterHooks()
	print("[HydroneerAP - Hooks] - Player exiting, removing hooks\n")
	local ok, err = pcall(function() Hooks:Unregister() end)
	if not ok then
		print("[HydroneerAP - Hooks] - Hooks:Unregister failed: " .. tostring(err) .. "\n")
	end
end
ExecuteInGameThread(function()
    RegisterHook(
        "/Game/GM_Hydroneer.GM_Hydroneer_C:OnCompleted_04443C294CDB96DED26005BF09499B5C",
        function(context, ...)
            RegisterHooks()
        end
    )
end)

ExecuteInGameThread(function()
    RegisterHook(
        "/Game/BP_GameController.BP_GameController_C:ReceiveDestroyed",
        function(context, ...)
            UnregisterHooks()
        end
    )
end)
ExecuteInGameThread(function()
    RegisterHook(
        "/Game/UI/MainMenu/UI_Menu_SaveManager.UI_Menu_SaveManager_C:SaveSelected",
        function(ctx, save)
            local ok, s = pcall(function() return save:get():ToString() end)
            if ok and s and s ~= "" then
                CurrentSlot = s
                print("Slot: " .. s .. "\n")
            end
        end
    )
end)