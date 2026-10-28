---Battle-related hooks
---@class ShopHooks
local DirtHooks = {}



---Register all battle hooks
---@param hookManager HookManager
---@param dependencies table
function DirtHooks:Register(hookManager, dependencies)
    local logger = dependencies.logger

    hookManager:Register(
        "/Game/WorldObj/Items/Resources/BP_ParentRawResource.BP_ParentRawResource_C:ReceiveBeginPlay",
        function(context, ...)
            self:OnChunkMaterial(context, ...)
        end,
        "Dirt - ReceiveBeginPlay"
    )
    logger:info("Dirt hooks registered")
end

function DirtHooks:OnChunkMaterial(context, ...)
    local chunk = context:get()
    print("Chunk: " .. chunk:GetFullName() .. "\n")

    for i, p in ipairs({...}) do
        local ok, v = pcall(function() return p:get() end)
        local s = tostring(v)
        if ok and type(v) == "userdata" then
            local ok2, name = pcall(function() return v:GetFullName() end)
            if ok2 then s = name end
        end
        print(string.format("  arg %d = %s\n", i, s))
    end
end

return DirtHooks