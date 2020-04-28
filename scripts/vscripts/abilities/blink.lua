blink = class({})


function blink:OnSpellStart()
    if not IsServer() then
        return nil
    end

    local caster = self:GetCaster()
    local caster_pos = caster:GetOrigin()
    local target_pos = self:GetCursorPosition()
    if self.pos ~= nil then
        target_pos = self.pos
        self.pos = nil
    end
    local direction = target_pos - caster_pos

    local range = self:GetSpecialValueFor("range")
    if direction:Length2D() > range then
        target_pos = caster_pos + range * direction:Normalized()
    end

    ProjectileManager:ProjectileDodge(caster)

    caster:EmitSound("soundevents/game_sounds_heroes/game_sounds_queenofpain.vsndevts")
   

    local index = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_blink_start_v2.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:ReleaseParticleIndex(index)

    Timers:CreateTimer(0.01, function()
        caster:SetOrigin(target_pos)
        FindClearSpaceForUnit(caster, target_pos, true)

        local index = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_blink_end_v2.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:ReleaseParticleIndex(index)
    end)
end

function blink:CastFilterResultLocation(target)
    return self:CastResolveLocation(target, false)
end

function blink:GetCustomCastErrorLocation(target)
    return self:CastResolveLocation(target, true)
end

function blink:CastResolveLocation(target, error)
    if not IsServer() then
        return nil
    end

    local caster = self:GetCaster()
    local caster_pos = caster:GetOrigin()
    local direction = target - caster_pos

    for i = 0, 7 do
        local new_target = target - 100 * i * direction:Normalized()
        if GridNav:IsTraversable(new_target) then
            self.pos = new_target
            if not error then
                return UF_SUCCESS
            end
        end
    end
    if error then
        return "Targeted point not pathable"
    else
        return UF_FAIL_CUSTOM
    end
end