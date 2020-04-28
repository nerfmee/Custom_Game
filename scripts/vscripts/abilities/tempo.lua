LinkLuaModifier("mod__tempo", "modifiers/mod__tempo", LUA_MODIFIER_MOTION_NONE)

tempo = class({})


function tempo:GetIntrinsicModifierName()
    return "mod__tempo"
end