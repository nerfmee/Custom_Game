function item_refresher_datadriven_on_spell_start(keys)
	--Refresh all abilities on the caster.
	for i=0, 15, 1 do  --The maximum number of abilities a unit can have is currently 16.
		local current_ability = keys.caster:GetAbilityByIndex(i)
		if current_ability ~= nil then
			current_ability:EndCooldown()
		end
	end
end	