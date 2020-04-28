function boomerang( args )
  local caster = args.caster
  local ability = args.ability
  local ability_level = ability:GetLevel() 
  local random = RandomInt( 0, 100 )
  local vector = caster:GetForwardVector()
print(random)
  local injump_speed = 1
  local injump_distance = 1
  local sound = "Hero_Enchantress.Impetus"
  if caster:HasModifier("modifier_injump") then
  sound = "Hero_Enchantress.Impetus"
  injump_speed = 270
  injump_distance = 150
  end
  
  caster:EmitSound(sound)

-- dummys
  local target = args.target  
  local dummys = CreateUnitByName('npc_dummy_sphere', caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
  dummys:SetOwner(caster)
  local facevec = args.target_points[1] - dummys:GetAbsOrigin()
  facevec = facevec:Normalized()
  facevec.z = 0
  dummys:SetForwardVector(facevec)
  Physics:Unit(dummys) 
  dummys:FollowNavMesh(false)
  dummys:SetPhysicsFriction(0)
  dummys:SetGroundBehavior(PHYSICS_GROUND_LOCK)
  dummys:PreventDI(true)
  dummys:SetPhysicsVelocity(caster:GetForwardVector() * (1600 + injump_speed))
  dummys:SetHullRadius(6)
  local vec1 = dummys:GetAbsOrigin()
  vec1.z = 0
  dummys:SetAbsOrigin( vec1 + (dummys:GetForwardVector() * 110) )
-- skills
  dummys:FindAbilityByName("hide_sphere"):SetLevel(1) 
     local particle = ParticleManager:CreateParticle("particles/boomerang/boomerang.vpcf",PATTACH_ABSORIGIN_FOLLOW,dummys) 
     --dummys:EmitSound("Hero_Shredder.Chakram")
  Timers:CreateTimer( 0.3, function()
            distance = caster:GetAbsOrigin() - dummys:GetAbsOrigin()
            direction = distance:Normalized()
            dummys:SetPhysicsAcceleration(direction * (1900 + injump_speed))
            if dummys:IsAlive() then 
             return 0.1
           else
            end
            end)
Timers:CreateTimer( 3.0, function()
dummys:EmitSound("Hero_Shredder.TimberChain.Damage")
UTIL_Remove(dummys)
end)

Timers:CreateTimer( 0.01, function()

  if dummys:IsAlive() then 
    local position = dummys:GetAbsOrigin()
    local found_targets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, 95, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    local damageTable = {
             attacker = caster,
             damage = 999,
             damage_type = DAMAGE_TYPE_PHYSICAL,
             }
    for _,unitonfire in pairs(found_targets) do
             damageTable.victim = unitonfire
             ApplyDamage(damageTable)
             unitonfire:EmitSound("Hero_Shredder.Chakram.Target")
          if unitonfire:GetUnitName() == "npc_dummy_sphere" then
           unitonfire:EmitSound("Hero_Tinker.LaserImpact")
     end
    end
    GridNav:DestroyTreesAroundPoint( position, 95, true )
    return 0.1
      
  else
  
    end
end)
end