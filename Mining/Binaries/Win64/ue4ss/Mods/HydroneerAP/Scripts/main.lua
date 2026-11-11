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
HooksRegistered = false


local function GetGM()
    local gm = FindFirstOf("GM_Hydroneer_C")
    if gm and gm:IsValid() and not gm:GetFullName():find("Default__", 1, true) then
        return gm
    end
end

local function QuerySlot()
    local lib = StaticFindObject("/Game/BPFL_Game.Default__BPFL_Game_C")
    if not (lib and lib:IsValid()) then return nil end
    local ctx = GetGM() or FindFirstOf("BP_GameState_C")
    local out = {}
    local ok = pcall(function() lib:GetRootSaveSlot(ctx, out) end)
    if not ok or out.Slot == nil then return nil end
    local ok2, s = pcall(function() return out.Slot:ToString() end)
    if ok2 and s and s ~= "" then return s end
    return nil
end

local function GetSlotWhenReady(tries)
    local s = QuerySlot()
    if s then CurrentSlot = s; print("Slot: " .. s); return end
    if (tries or 0) < 20 then
        ExecuteWithDelay(500, function() GetSlotWhenReady((tries or 0) + 1) end)
    else
        print("Slot not available after retries")
    end
end

local function IsInGame()
    local gm = GetGM()
    return gm ~= nil and gm["InGame?"] == true
end

print("[HydroneerAP] Mod loaded!")
Logger:initialize()   -- sets logFile so Logger doesn't fall back to Debug.print

local function RegisterHooks()
	print("[HydroneerAP - Hooks] - Loading completed, registering hooks\n")
	local ok, err = pcall(function() Hooks:Register() end)
	HooksRegistered = true
	if not ok then
		print("[HydroneerAP - Hooks] - Hooks:Register failed: " .. tostring(err) .. "\n")
	end
end
local function UnregisterHooks()
	print("[HydroneerAP - Hooks] - Player exiting, removing hooks\n")
	local ok, err = pcall(function() Hooks:Unregister() end)
	HooksRegistered = false
	if not ok then
		print("[HydroneerAP - Hooks] - Hooks:Unregister failed: " .. tostring(err) .. "\n")
	end
end

-- Execute the hooking function if in-game, for debug maybe or AP-reconnection?
ExecuteInGameThread(function()
	if HooksRegistered == false then
		if IsInGame() then
			RegisterHooks()
			print(IsInGame())
			GetSlotWhenReady()
			SaveHooks:LoadGame()
		end
	end
end)

ExecuteInGameThread(function()
    RegisterHook(
        "/Game/GM_Hydroneer.GM_Hydroneer_C:OnCompleted_04443C294CDB96DED26005BF09499B5C",
        function(context, ...)
			if HooksRegistered == false then
				if IsInGame() then
					RegisterHooks()
					print(IsInGame())
					GetSlotWhenReady()
					SaveHooks:LoadGame()
				end
			end
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