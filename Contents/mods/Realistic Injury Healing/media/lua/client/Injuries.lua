--[[
*
*              ^_^         Y U M M Y         ^_^
*
*                 ~ Deliciously Made by YUMMY ~
*
*                          :3  :3  :3
*
]]

local Injuries = {}

Injuries.OnInjury = {}
Injuries.EveryOneMinute = {}
Injuries.OnGameStart = {}

Injuries.OnInjury.Fracture = function(bodyPart, fractureEffect, effectMultiplier)
    if (bodyPart:getGarlicFactor() or bodyPart:getPlantainFactor()) > 0 then
        fractureEffect = fractureEffect + 0.0002
    end

    fractureEffect = fractureEffect * effectMultiplier * Injuries.dayLengthEffect
    bodyPart:setFractureTime(bodyPart:getFractureTime() - fractureEffect)
end

Injuries.OnInjury.Burn = function(bodyPart, burnEffect, effectMultiplier)
    burnEffect = burnEffect * effectMultiplier * Injuries.dayLengthEffect
    bodyPart:setBurnTime(bodyPart:getBurnTime() - burnEffect)
end

Injuries.OnInjury.Scratch = function(bodyPart, scratchEffect, effectMultiplier)
    scratchEffect = scratchEffect * effectMultiplier * Injuries.dayLengthEffect
    bodyPart:setScratchTime(bodyPart:getScratchTime() - scratchEffect)
end

Injuries.OnInjury.Cut = function(bodyPart, cutEffect, effectMultiplier)
    cutEffect = cutEffect * effectMultiplier * Injuries.dayLengthEffect
    bodyPart:setCutTime(bodyPart:getCutTime() - cutEffect)
end

Injuries.OnInjury.Bite = function(bodyPart, biteEffect, effectMultiplier)
    biteEffect = biteEffect * effectMultiplier * Injuries.dayLengthEffect
    bodyPart:setBiteTime(bodyPart:getBiteTime() - biteEffect)
end

-- EveryOneMinute events

local injuryMultipliers = { -- Injury multipliers
    Fracture = { effectMultiplier = 5, activityMultiplier = 1.5 },
    Burn = { effectMultiplier = 2, activityMultiplier = 1.0 },
    Scratch = { effectMultiplier = 3, activityMultiplier = 0.5 },
    Cut = { effectMultiplier = 1, activityMultiplier = 1.0 },
    Bite = { effectMultiplier = 2, activityMultiplier = 2.0 },
}

Injuries.EveryOneMinute.applyInjuryEffects = function()
    local bodyDamage = getPlayer():getBodyDamage()
    local bodyParts = bodyDamage:getBodyParts()

    local dynamicEffectsEnabled = SandboxVars.Injuries.DynamicEffectsEnabled

    local modData = getPlayer():getModData()

    local hasInjury = false

    for i = 0, bodyParts:size() - 1 do
        local bodyPart = bodyParts:get(i)
        local bodyPartType = tostring(bodyPart:getType())

        for injury, func in pairs(Injuries.OnInjury) do
            if SandboxVars.Injuries[injury] then
                local injuryTime = bodyPart["get" .. injury .. "Time"](bodyPart)

                if injuryTime > 0 then
                    hasInjury = true

                    if not modData[bodyPartType].initialTime[injury] then
                        local getInjuryTime = bodyPart["get" .. injury .. "Time"]
                        local setInjuryTime = bodyPart["set" .. injury .. "Time"]

                        setInjuryTime(bodyPart, injuryTime * SandboxVars.Injuries[injury .. "InitialMultiplier"])

                        modData[bodyPartType].initialTime[injury] = getInjuryTime(bodyPart)

                        print(modData[bodyPartType].initialTime[injury])
                    end

                    if dynamicEffectsEnabled then
                        local injuryEffect = Injuries.sandboxEffect

                        local injuryTimeLimitReached = injuryTime >
                            modData[bodyPartType].initialTime[injury] * SandboxVars.Injuries
                            [injury .. "LimitMultiplier"]

                        if not injuryTimeLimitReached then
                            if bodyPart:bandaged() then
                                if injury == "Fracture" then
                                    if bodyPart:isBandageDirty() then
                                        injuryEffect = injuryEffect + 0.0005
                                    else
                                        injuryEffect = injuryEffect + 0.0010
                                    end
                                else
                                    injuryEffect = injuryEffect + Injuries.EveryOneMinute.getBandageEffect(bodyPart)
                                end
                            end

                            local moodlesEffect = Injuries.EveryOneMinute.getMoodlesEffect()
                            local activityEffect = Injuries.EveryOneMinute.getActivityEffect(bodyPartType, injury)

                            injuryEffect = injuryEffect + moodlesEffect + activityEffect

                            func(bodyPart, injuryEffect, injuryMultipliers[injury].effectMultiplier)

                            modData.weaponEffect = 0
                        end
                    end
                elseif modData[bodyPartType].initialTime[injury] then
                    modData[bodyPartType].initialTime[injury] = {}
                end
            end
        end
    end

    modData.hasInjury = hasInjury
end

local moodles = {                                                                         -- 0.006
    { type = MoodleType.FoodEaten,    effects = { 0.0012, 0.0024, 0.0036, 0.0048 } },     -- Saturation
    { type = MoodleType.Hungry,       effects = { -0.0010, -0.0020, -0.0030, -0.0040 } }, -- Hunger
    { type = MoodleType.Tired,        effects = { -0.0012, -0.0024, -0.0048, -0.0060 } }, -- Tiredness
    { type = MoodleType.Injured,      effects = { -0.0010, -0.0020, -0.0030, -0.0040 } }, -- General health
    { type = MoodleType.Thirst,       effects = { -0.0003, -0.0006, -0.0012, -0.0024 } }, -- Thirst
    { type = MoodleType.Sick,         effects = { -0.0003, -0.0006, -0.0012, -0.0024 } }, -- Sickness
    { type = MoodleType.Stress,       effects = { -0.0001, -0.0003, -0.0006, -0.0010 } }, -- Stress
    { type = MoodleType.Hyperthermia, effects = { -0.0003, -0.0006, -0.0012, -0.0020 } }, -- Hyperthermia
    { type = MoodleType.Hypothermia,  effects = { -0.0003, -0.0006, -0.0012, -0.0020 } }, -- Hypothermia
    { type = MoodleType.Bleeding,     effects = { -0.0010, -0.0020, -0.0030, -0.0040 } }, -- Bleeding
    { type = MoodleType.Wet,          effects = { -0.0002, -0.0004, -0.0008, -0.0012 } }, -- Wet
    { type = MoodleType.HasACold,     effects = { -0.0004, -0.0008, -0.0012, -0.0016 } }, -- Cold
}

local bandageTypes = { -- Bandage types
    AlcoholRippedSheets = 0.0005,
    Bandage = 0.0015,
    Bandaid = 0.0012,
    AlcoholBandage = 0.0020,
}

local bodyTypes = { -- Body types
    Hand_L = "Arm",
    Hand_R = "Arm",
    ForeArm_L = "Arm",
    ForeArm_R = "Arm",
    UpperArm_L = "Arm",
    UpperArm_R = "Arm",
    Torso_Upper = "Body",
    Torso_Lower = "Body",
    Head = "Body",
    Neck = "Body",
    Groin = "Leg",
    UpperLeg_L = "Leg",
    UpperLeg_R = "Leg",
    LowerLeg_L = "Leg",
    LowerLeg_R = "Leg",
    Foot_L = "Leg",
    Foot_R = "Leg",
}

local bodyTypeValue = { Arm = 0.0005, Body = 0.0010, Leg = 0.0010 }

local activityMultipliers = {
    stand = { Arm = 1, Body = 1, Leg = 1 },
    sit = { Arm = 2, Body = 1.5, Leg = 2 },
    sleep = { Arm = 3, Body = 2.5, Leg = 3 },
    run = { Arm = -2, Body = -2, Leg = -3 },
    sprint = { Arm = -4, Body = -4, Leg = -6 },
    weaponHit = { Arm = -1, Body = -1.5, Leg = -2 }
}

Injuries.EveryOneMinute.getMoodlesEffect = function() -- get Moodles Effect
    local moodlesEffect = 0

    for _, moodle in ipairs(moodles) do
        local level = getPlayer():getMoodleLevel(moodle.type)

        if level > 0 then
            moodlesEffect = moodlesEffect + moodle.effects[level]
        end
    end

    return moodlesEffect
end

Injuries.EveryOneMinute.getBandageEffect = function(bodyPart) -- get Bandage Effect
    local bandageEffect = 0
    local bandageType = bodyPart:getBandageType()

    if bodyPart:isBandageDirty() then
        bandageEffect = -0.0020
    elseif bandageType and bandageTypes[bandageType:match("%.([^%.]+)$")] then
        bandageEffect = bandageTypes[bandageType:match("%.([^%.]+)$")]
    end

    return bandageEffect;
end

Injuries.EveryOneMinute.getActivityEffect = function(bodyPartType, injury) -- get Activity Effect
    local player = getPlayer()

    local bodyType = bodyTypes[bodyPartType]

    local activity = "stand"

    if player:isAsleep() then
        activity = "sleep"
    elseif player:isSitOnGround() then
        activity = "sit"
    elseif player:isRunning() then
        activity = "run"
    elseif player:isSprinting() then
        activity = "sprint"
    end

    local injuryMultiplier = injuryMultipliers[injury].activityMultiplier

    local bodyTypeEffect = bodyTypeValue[bodyType] * injuryMultiplier * activityMultipliers[activity][bodyType]
    local weaponEffect = player:getModData().weaponEffect * injuryMultiplier * activityMultipliers["weaponHit"]
        [bodyType]

    local fitnessEffect = bodyTypeEffect + weaponEffect

    return fitnessEffect
end


-- OnPlayerAttackFinished event

Events.OnPlayerAttackFinished.Add(function(player, weapon)
    local modData = player:getModData()

    if not modData.hasInjury then return end
    if not weapon or (not weapon:isRanged() and weapon:getWeight() < 2) then return end

    local weaponType = weapon:getType()
    local weaponEffect = 0

    if weaponType:contains("Pistol") then
        weaponEffect = 0.0010
    elseif weaponType:contains("Rifle") then
        weaponEffect = 0.0020
    elseif weaponType:contains("Shotgun") then
        weaponEffect = 0.0030
    else
        weaponEffect = 0.0015
    end

    modData.weaponEffect = modData.weaponEffect + weaponEffect
end)


-- OnGameStart events

Injuries.OnGameStart.setSandoxEffect = function()
    local sandboxEffect = 0

    -- Traits

    local isFastHealer = getPlayer():HasTrait("FastHealer")
    local isSlowHealer = getPlayer():HasTrait("SlowHealer")

    if isFastHealer then
        sandboxEffect = 0.0024
    elseif isSlowHealer then
        sandboxEffect = -0.0024
    end

    -- Injury Severity

    local injurySeverity = SandboxVars.InjurySeverity

    if injurySeverity == 1 then
        sandboxEffect = sandboxEffect + 0.0012
    elseif injurySeverity == 3 then
        sandboxEffect = sandboxEffect - 0.0016
    end

    Injuries.sandboxEffect = sandboxEffect
end

Injuries.OnGameStart.setStartedModData = function()
    local modData = getPlayer():getModData()

    local bodyDamage = getPlayer():getBodyDamage()
    local bodyParts = bodyDamage:getBodyParts()

    for i = 0, bodyParts:size() - 1 do
        local bodyPart = bodyParts:get(i)
        local bodyPartType = tostring(bodyPart:getType())

        print("some of god")

        if not modData[bodyPartType] then modData[bodyPartType] = {} end
        if not modData[bodyPartType].initialTime then modData[bodyPartType].initialTime = {} end
    end

    if not modData.weaponEffect then modData.weaponEffect = 0 end
end

Injuries.OnGameStart.setDayLengthEffect = function()
    if SandboxVars.DayLength >= 3 then
        Injuries.dayLengthEffect = SandboxVars.DayLength - 2
    elseif SandboxVars.DayLength == 2 then
        Injuries.dayLengthEffect = 0.5
    else
        Injuries.dayLengthEffect = 0.25
    end
end

Events.OnGameStart.Add(function()
    Injuries.OnGameStart.setSandoxEffect()
    Injuries.OnGameStart.setStartedModData()
    Injuries.OnGameStart.setDayLengthEffect()

    Events.EveryOneMinute.Add(Injuries.EveryOneMinute.applyInjuryEffects)
end)
