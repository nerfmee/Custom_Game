mod__repel = class({})


function mod__repel:GetTexture()
    return "repel"
end

function mod__repel:GetStatusEffectName()
    return "particles/status_fx/status_effect_omnislash.vpcf"
end

function mod__repel:GetEffectName()
    return "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8.vpcf"
end

function mod__repel:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function mod__repel:DeclareFunctions()
    return {
        --MODIFIER_EVENT_ON_ORDER,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

--function mod__repel:OnOrder(keys)
--    if not IsServer() then
--        return nil
--    end
--
--    local parent = self:GetParent()
--
--    if keys.unit == parent and keys.order_type <= 9 and parent:HasModifier("mod__repel") then
--        parent:RemoveModifierByName("mod__repel")
--    end
--end

function mod__repel:GetModifierIncomingDamage_Percentage()
    return -100
end

function mod__repel:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true
    }
end