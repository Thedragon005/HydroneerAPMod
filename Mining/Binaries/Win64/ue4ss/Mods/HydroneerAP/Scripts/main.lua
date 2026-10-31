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
	print("Loading completed, registering hooks\n")
	local ok, err = pcall(function() Hooks:Register() end)
	if not ok then
		print("[HydroneerAP] Hooks:Register failed: " .. tostring(err) .. "\n")
	end
end
ExecuteInGameThread(function()
	RegisterHook("/Game/GM_Hydroneer.GM_Hydroneer_C:OnCompleted_04443C294CDB96DED26005BF09499B5C", function(ctx, newPawn)
			RegisterHooks() 
			print("HI")
		-- start your tracking / load your sidecar file here
	end)
end)
