function on_status_check( event )    
  local caster = event.caster
  local ability = event.ability
  local steamID = PlayerResource:GetSteamAccountID(caster:GetPlayerID())
Timers:CreateTimer( 1, function()
  print(steamID)
   if steamID == 80974978 or steamID == 165298899 or steamID == 163465023 then
    caster.CustomColor = {90, 235, 255}
    
        if caster:HasModifier("modifier_hephaestus") then
          else
          ability:ApplyDataDrivenModifier(caster, caster, "modifier_hephaestus", {})
         
             --if caster:HasAbility("shockwave_gold") then
        
              -- Add
              caster:AddAbility("mirana_leap"):SetLevel(1) 
       print("Add")
              -- Swap
              caster:SwapAbilities("shockwave_gold", "shockwave_hephaestus", false, true)
  print("Swap")
              -- Remove pustishku
              caster:RemoveAbility("shockwave_gold") 
        print("pustishku")
            -- end
     
          end
    end
  end)

end