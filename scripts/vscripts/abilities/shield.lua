LinkLuaModifier("mod__shield", "modifiers/mod__shield", LUA_MODIFIER_MOTION_NONE)

shield = class({})


function shield:OnSpellStart()
    if not IsServer() then
        return nil
    end

    local caster = self:GetCaster()
    caster:EmitSound("Hero_TemplarAssassin.Refraction")
    caster:AddNewModifier(caster, self, "mod__shield", { duration = self:GetSpecialValueFor("duration") })
end