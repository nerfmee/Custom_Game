function forgotten_skills( event )    
  local caster = event.caster
  local ability = event.ability
  local steamID = PlayerResource:GetSteamAccountID(caster:GetPlayerID())

  print(steamID)
  if caster:HasModifier("modifier_forgotten_skills_active") then
  else
      caster:AddAbility("dagger_throw"):SetLevel(1) 
      caster:SwapAbilities("invisible", "dagger_throw", false, true)

      ability:ApplyDataDrivenModifier(caster, unit, "modifier_forgotten_skills_active", {6.25})
      Timers:CreateTimer( 6, function()
        -- Add
      caster:SwapAbilities("invisible", "dagger_throw", false, true)
      caster:RemoveAbility("dagger_throw") 

      end)
  end
    
     
end