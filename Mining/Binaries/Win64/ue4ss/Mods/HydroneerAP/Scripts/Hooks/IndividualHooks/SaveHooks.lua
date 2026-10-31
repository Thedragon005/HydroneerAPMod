---Save-related hooks
---@class SaveHooks
local SaveHooks = {}
local DirtHooks     = require "Hooks.IndividualHooks.DirtHooks"
local TableHelpers 	= require "Utils.TableHelpers"
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
function SaveHooks:Register(hookManager, dependencies)
    local logger = dependencies.logger

    hookManager:Register(
        "/Game/GM_Hydroneer.GM_Hydroneer_C:OnSaveComplete__DelegateSignature",
        --BndEvt__SaveButton_K2Node_ComponentBoundEvent_1_OnButtonClickedEvent__DelegateSignature
        function(context, ...)
            self:SaveGame(context)
			print("OnSaveComplete")
			--self.dumpProps(context, ...)
        end,
        "Save - OnSaveComplete"
    )
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
        "/Game/BP_GameController.BP_GameController_C:ReceiveBeginPlay",
        --BndEvt__SaveButton_K2Node_ComponentBoundEvent_1_OnButtonClickedEvent__DelegateSignature
		function(context, ...)
            self:SaveGame(context)
			print("ReceiveBeginPlay")
			--self.dumpProps(context, ...)
        end,
        "Save - ActorPreSave"
    )
    logger:info("Save hooks registered")
	print("Save hooks registered")
end

function SaveHooks:SaveGame(logger,hookManager)
   print("-----------------------------------")
   print("Saving")
   print(context)
   print(TableHelpers.Dump(GlobalOreDict))
end

return SaveHooks