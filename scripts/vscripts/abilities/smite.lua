smite = class({})


function smite:OnSpellStart()
    if not IsServer() then
        return nil
    end

    local caster = self:GetCaster()
    local caster_pos = caster:GetOrigin()
    local target_pos = self:GetCursorPosition()
    local direction = target_pos - caster_pos

    local range = self:GetSpecialValueFor("range")
    local radius = self:GetSpecialValueFor("radius")
    local speed = self:GetSpecialValueFor("speed")

    local projectile = {
        Ability = self,
        EffectName = "particles/smite.vpcf",
        vSpawnOrigin = caster_pos,
        fDistance = (range * direction:Normalized()):Length2D(),
        fStartRadius = radius,
        fEndRadius = radius,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        bDeleteOnHit = false,
        vVelocity = speed * Vector(direction.x, direction.y, 0):Normalized(),
        bProvidesVision = true,
        iVisionTeamNumber = caster:GetTeamNumber(),
        iVisionRadius = radius,
        fExpireTime = GameRules:GetGameTime() + 2.0
    }
    ProjectileManager:CreateLinearProjectile(projectile)
end

function smite:OnProjectileHit(target, location)
    if not IsServer() then
        return nil
    end

    local damage = {
        victim = target,
        attacker = self:GetCaster(),
        damage = self:GetSpecialValueFor("damage"),
        damage_type = self:GetAbilityDamageType(),
        ability = self
    }
    ApplyDamage(damage)
end

function smite:GetCastRange()
    return self:GetSpecialValueFor("range")
end

function smite:OnAbilityPhaseStart()
    if not IsServer() then
        return nil
    end

    local caster = self:GetCaster()
    caster:EmitSound("Hero_Magnataur.ShockWave.Cast")
    return true
end

function smite:OnAbilityPhaseInterrupted()
    if not IsServer() then
        return nil
    end

    local caster = self:GetCaster()
    caster:StopSound("Hero_Magnataur.ShockWave.Cast")
    return true
end