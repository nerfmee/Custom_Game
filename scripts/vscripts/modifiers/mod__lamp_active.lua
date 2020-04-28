mod__lamp_active = class({})


function mod__lamp_active:IsHidden()
    return true
end

function mod__lamp_active:OnCreated()
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()
    local caster = self:GetCaster()

    parent:SetTeam(caster:GetTeam())

    self.index = ParticleManager:CreateParticle("particles/econ/items/oracle/ti9_cache_oracle_grand_hierophant/ti9_cache_oracle_ambient_weapon_ball_rays.vpcf", PATTACH_POINT_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(self.index, 0, parent, PATTACH_POINT_FOLLOW, "attach_lantern_glow", parent:GetOrigin(), true)
end

function mod__lamp_active:OnDestroy()
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()

    parent:SetTeam(DOTA_TEAM_NEUTRALS)

    if self.index ~= nil then
        ParticleManager:DestroyParticle(self.index, false)
    end
end

function mod__lamp_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end

function mod__lamp_active:GetModifierModelChange()
    return "models/items/courier/xianhe_stork/xianhe_stork_flying.vmdl"
end

function mod__lamp_active:CheckState()
    return {
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end