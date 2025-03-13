--[[
*
*              ^_^         Y U M M Y         ^_^
*
*                 ~ Deliciously Made by YUMMY ~
*
*                          :3  :3  :3
*
]]

local applySplint = ISSplint.perform
local applyComfrey = ISComfreyCataplasm.perform

function ISSplint:perform()
    applySplint(self)

    if self.doIt then
        local splintFactor = self.doctorLevel / 2
        self.bodyPart:setSplintFactor(0.5 + splintFactor / SandboxVars.Injuries.SplintInefficiencyMultiplier)
    end
end

function ISComfreyCataplasm:perform()
    applyComfrey(self)

    self.bodyPart:setComfreyFactor(self.bodyPart:getComfreyFactor() * SandboxVars.Injuries.ComfreyDurationMultiplier)
end
