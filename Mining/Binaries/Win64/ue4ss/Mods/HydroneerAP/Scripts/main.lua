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


print("[HydroneerAP] Mod loaded!")
Logger:initialize()   -- sets logFile so Logger doesn't fall back to Debug.print

local ok, err = pcall(function() Hooks:Register() end)
if not ok then
    print("[HydroneerAP] Hooks:Register failed: " .. tostring(err) .. "\n")
end