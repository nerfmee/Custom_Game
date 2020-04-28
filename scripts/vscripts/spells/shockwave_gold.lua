function shockwave( args )
  local caster = args.caster
  local ability = args.ability
  local ability_level = ability:GetLevel() 
  local random = RandomInt( 0, 100 )
  local vector = caster:GetForwardVector()
print(random)
  local injump_speed = 1
  local injump_distance = 1
  local sound = "Hero_Magnataur.ShockWave.Cast"
  local particle = "particles/shockwave_gold/shockwave_gold.vpcf"
  if caster:HasModifier("modifier_injump") then
  sound = "Hero_Magnataur.ShockWave.Particle.Anvil"
  particle = "particles/deadwave_gold/deadwave_gold.vpcf"
  injump_speed = 470
  injump_distance = 300
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
  dummys:SetPhysicsVelocity(caster:GetForwardVector() * (1900 + injump_speed))
  dummys:SetHullRadius(6)
  local vec1 = dummys:GetAbsOrigin()
  vec1.z = 0
  dummys:SetAbsOrigin( vec1 + (dummys:GetForwardVector() * 110) )
-- skills
  dummys:FindAbilityByName("hide_sphere"):SetLevel(1) 
 


local projectile = {
  EffectName = particle,
  vSpawnOrigin = {unit=caster, attach="attach_attack1", offset=Vector(0,0,-40)},
  fDistance = 1200 + injump_distance,
  fStartRadius = 120,
  fEndRadius = 120,
  Source = caster,
  vVelocity = vector * (1900 + injump_speed),
  UnitBehavior = PROJECTILES_NOTHING,
  bMultipleHits = true,
  bIgnoreSource = true,
  TreeBehavior = PROJECTILES_NOTHING,
  bCutTrees = true,
  WallBehavior = PROJECTILES_NOTHING,
  GroundBehavior = PROJECTILES_NOTHING,
  fGroundOffset = 80,
  nChangeMax = 1,
  bRecreateOnChange = true,
  bZCheck = false,
  bGroundLock = true,
  bProvidesVision = true,
  iVisionRadius = 400,
  OnTreeHit = function(self, tree)
  end,
  OnFinish = function(self, pos)
  UTIL_Remove(dummys)
  end,
  UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() or unit:GetUnitName() == "npc_dummy_unit" end,
  OnUnitHit = function(self, unit)
        local target = unit
        local damageTable = {
                        victim = target,
                        attacker = caster,
                        damage = 999,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                }
        ApplyDamage(damageTable)

        if unit:IsHero() then
  

        elseif unit:GetUnitName() == "npc_dummy_sphere" then
           unit:EmitSound("Hero_Tinker.LaserImpact")
          
        end
  end
}

Projectiles:CreateProjectile(projectile)
   
Timers:CreateTimer( 0.3, function()
  if dummys:IsAlive() then 
    return 0.2
  else
    projectile:Destroy(projID)
  end
end )
end