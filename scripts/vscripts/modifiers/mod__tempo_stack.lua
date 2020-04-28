mod__tempo_stack = class({})


function mod__tempo_stack:OnCreated()
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()
    self.index = ParticleManager:CreateParticle("", PATTACH_OVERHEAD_FOLLOW, parent)
    --ParticleManager:SetParticleControl(self.index, 1, Vector(0, self:GetStackCount(), 0))
end

function mod__tempo_stack:OnDestroy()
    if not IsServer() then
        return nil
    end

    if self.index ~= nil then
        ParticleManager:DestroyParticle(self.index, false)
    end
end

function mod__tempo_stack:OnRefresh()
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    ParticleManager:SetParticleControl(self.index, 1, Vector(0, self:GetStackCount(), 0))

    if self:GetStackCount() >= ability:GetSpecialValueFor("stacks_required") then
        for i = 0, 3 do
            local ability = parent:GetAbilityByIndex(i)
            if ability ~= nil then
                ability:EndCooldown()
            end
        end

        parent:EmitSound("Hero_EarthShaker.Totem.TI6.Layer")
        local index = ParticleManager:CreateParticle("", PATTACH_POINT_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(index, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetOrigin(), true)
        ParticleManager:ReleaseParticleIndex(index)

        parent:RemoveModifierByName("mod__tempo_stack")
    end
end
