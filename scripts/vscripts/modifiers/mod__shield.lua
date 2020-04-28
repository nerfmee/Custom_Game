mod__shield = class({})


function mod__shield:OnCreated()
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()
    self.index = ParticleManager:CreateParticle("particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction.vpcf", PATTACH_POINT_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(self.index, 1, parent, PATTACH_POINT_FOLLOW, "follow_origin", parent:GetOrigin(), true)
end

function mod__shield:OnDestroy()
    if not IsServer() then
        return nil
    end

    if self.index ~= nil then
        ParticleManager:DestroyParticle(self.index, false)
    end
end

function mod__shield:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

function mod__shield:GetModifierIncomingDamage_Percentage()
    return -100
end