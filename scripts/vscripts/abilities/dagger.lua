dagger = class({})


function dagger:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
    caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")

    local projectile = {
        EffectName = "particles/econ/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_stifling_dagger_model.vpcf",
        Dodgeable = true,
        Ability = self,
        ProvidesVision = false,
        bVisibleToEnemies = true,
        iMoveSpeed = self:GetSpecialValueFor("speed"),
        Source = caster,
        Target = target,
        bReplaceExisting = false
    }
    ProjectileManager:CreateTrackingProjectile(projectile)
end

function dagger:OnProjectileHit(target, location)
    if not IsServer() then
        return nil
    end

    if target ~= nil then
        target:EmitSound("Hero_PhantomAssassin.Dagger.Target")

        local damage = {
            victim = target,
            attacker = self:GetCaster(),
            damage = self:GetSpecialValueFor("damage"),
            damage_type = self:GetAbilityDamageType(),
            ability = self
        }
        ApplyDamage(damage)
    end
end

function dagger:GetCastRange()
    return self:GetSpecialValueFor("range")
end

function dagger:OnAbilityPhaseStart()
    if not IsServer() then
        return nil
    end

    local caster = self:GetCaster()
    caster:EmitSound("Hero_Invoker.ChaosMeteor.Cast")
    return true
end

function dagger:OnAbilityPhaseInterrupted()
    if not IsServer() then
        return nil
    end

    local caster = self:GetCaster()
    caster:StopSound("Hero_Invoker.ChaosMeteor.Cast")
    return true
end