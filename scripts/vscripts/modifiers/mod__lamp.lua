LinkLuaModifier("mod__lamp_active", "modifiers/mod__lamp_active", LUA_MODIFIER_MOTION_NONE)

mod__lamp = class({})


function mod__lamp:IsHidden()
    return true
end

function mod__lamp:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
    }
end

function mod__lamp:OnAttacked(keys)
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()

    if keys.target == parent then
        parent:AddNewModifier(keys.attacker, nil, "mod__lamp_active", { duration = 15 })
    end
end

function mod__lamp:GetModifierIncomingDamage_Percentage()
    return -100
end

function mod__lamp:GetModifierProvidesFOWVision()
    return 1
end

function mod__lamp:CheckState()
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()

    if parent:HasModifier("mod__lamp_active") and not GameRules.ROUND_IN_PROGRESS then
        parent:RemoveModifierByName("mod__lamp_active")
    end

    return {
        [MODIFIER_STATE_ATTACK_IMMUNE] = parent:HasModifier("mod__lamp_active") or not GameRules.ROUND_IN_PROGRESS,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = parent:HasModifier("mod__lamp_active") or not GameRules.ROUND_IN_PROGRESS
    }
end