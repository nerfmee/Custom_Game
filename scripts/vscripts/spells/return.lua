function return_n( event )
 local caster = event.caster
 local attacker = event.attacker
 local ability = event.ability
 local damage_taken = event.Damage

 if caster:HasModifier("modifier_stifling_dagger") then
 caster:EmitSound("Hero_Tinker.LaserImpact")
        --print("               caster = ", caster )
        --print("               target = ", target )
        --print("               unit = ", event.unit )
        --print("               attacker = ", attacker )

print( "0" )           
  local projectile = {
      EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
      Ability = ability,
      Target = attacker,
      Source = caster,
      bDodgeable = true,
      bProvidesVision = false,
      vSpawnOrigin = caster:GetAbsOrigin(),
      iMoveSpeed = 1200,
      iVisionRadius = 300,
      iVisionTeamNumber = caster:GetTeamNumber(),
      iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }

    ProjectileManager:CreateTrackingProjectile(projectile)
  print( "1" )
 end
end


function on_hit( keys )
  local caster = keys.caster
  local target = keys.target
  local ability = keys.ability
print( "2" )

  ability:ApplyDataDrivenModifier(caster, target, "modifier_stifling_dagger", {0.1})
  local damageTable = {
                        victim = target,
                        attacker = caster,
                        damage = 10000,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                      }
  ApplyDamage(damageTable)
  caster:EmitSound("Hero_PhantomAssassin.Dagger.Target")
end