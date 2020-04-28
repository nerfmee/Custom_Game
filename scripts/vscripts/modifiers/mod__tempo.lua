LinkLuaModifier("mod__tempo_stack", "modifiers/mod__tempo_stack", LUA_MODIFIER_MOTION_NONE)

mod__tempo = class({})


function mod__tempo:IsHidden()
    return true
end

function mod__tempo:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_PROJECTILE_DODGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function mod__tempo:OnProjectileDodge(keys)
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if keys.target == parent then
        self:UpdateStacks(ability:GetSpecialValueFor("stacks_from_dodge"))
    end
end

function mod__tempo:OnTakeDamage(keys)
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if keys.unit == parent and keys.damage == 0 and not parent:HasModifier("mod__repel") then
        self:UpdateStacks(ability:GetSpecialValueFor("stacks_from_dodge"))
    end
end

function mod__tempo:OnHeroKilled(keys)
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    if keys.unit == parent then
        self:UpdateStacks(ability:GetSpecialValueFor("stacks_from_kill"))
    end
end

function mod__tempo:OnAttackLanded(keys)
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()

    if keys.attacker == parent then
        if not keys.target:HasModifier("mod__shield") and not keys.target:HasModifier("mod__repel") then
            local index = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_tgt_serrakura.vpcf", PATTACH_POINT_FOLLOW, keys.attacker)
            ParticleManager:SetParticleControl(index, 1, keys.target:GetOrigin())
            ParticleManager:ReleaseParticleIndex(index)
        end
    end
end

function mod__tempo:UpdateStacks(amount)
    if not IsServer() then
        return nil
    end

    local parent = self:GetParent()
    local ability = self:GetAbility()

    local modifier = parent:FindModifierByName("mod__tempo_stack")
    if modifier == nil then
        modifier = parent:AddNewModifier(parent, ability, "mod__tempo_stack", {duration = ability:GetSpecialValueFor("stack_duration")})
    end
    if modifier ~= nil then
        modifier:SetStackCount(modifier:GetStackCount() + amount)
        modifier:ForceRefresh()
    end
end