---Battle-related hooks
---@class ShopHooks
local OverridePickUpHooks = {}



---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table
function OverridePickUpHooks:Register(hookManager, dependencies)
    local logger = dependencies.logger
	
	hookManager:Register(
        "/Game/WorldObj/Items/BP_ParentItem.BP_ParentItem_C:OverrideBeginPlay",
        function(context, ...)
            self:SwapItem(context, ...)
        end,
        "Dirt - OverrideBeginPlay"
    )
	
    logger:info("Dirt hooks registered")
end

function OverridePickUpHooks:SwapItem(context, newItem)
	local item = context:get()
    local item = newItem and newItem:get() or context:get() 
    if not (item and item:IsValid()) then return end

    local class = item:GetClass():GetFName():ToString()

    if class == "BP_PickaxeT1_C" then
		ExecuteWithDelay(100, function()
			ExecuteInGameThread(function()
				local controller = FindFirstOf("BP_GameController_C")
					if controller and controller:IsValid() then
						controller:DropItem({})
					end
			end)
		end)
    end
end

return OverridePickUpHooks