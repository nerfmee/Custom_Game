swap = class({})

--------------------------------------------------------------------------------

function swap:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------

function swap:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	if ( hTarget:IsCreep() and ( not self:GetCaster():HasScepter() ) ) or hTarget:IsAncient() then
		return UF_FAIL_CUSTOM
	end

	local nResult = UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

--------------------------------------------------------------------------------

function swap:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	if hTarget:IsAncient() then
		return "#dota_hud_error_cant_cast_on_ancient"
	end

	if hTarget:IsCreep() and ( not self:GetCaster():HasScepter() ) then
		return "#dota_hud_error_cant_cast_on_creep"
	end

	return ""
end

--------------------------------------------------------------------------------

function swap:GetCooldown( nLevel )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "nether_swap_cooldown_scepter" )
	end

	return self.BaseClass.GetCooldown( self, nLevel )
end

--------------------------------------------------------------------------------

function swap:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	ProjectileManager:ProjectileDodge(hCaster)
	ProjectileManager:ProjectileDodge(hTarget)
	if hCaster == nil or hTarget == nil or hTarget:TriggerSpellAbsorb( this ) then
		return
	end

	local vPos1 = hCaster:GetOrigin()
	local vPos2 = hTarget:GetOrigin()

	GridNav:DestroyTreesAroundPoint( vPos1, 300, false )
	GridNav:DestroyTreesAroundPoint( vPos2, 300, false )

	hCaster:SetOrigin( vPos2 )
	hTarget:SetOrigin( vPos1 )

	FindClearSpaceForUnit( hCaster, vPos2, true )
	FindClearSpaceForUnit( hTarget, vPos1, true )
	
	hTarget:Interrupt()

	local nCasterFX = ParticleManager:CreateParticle( "particles/swap/swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster )
	ParticleManager:SetParticleControlEnt( nCasterFX, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nCasterFX )

	local nTargetFX = ParticleManager:CreateParticle( "particles/swap/swap_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControlEnt( nTargetFX, 1, hCaster, PATTACH_ABSORIGIN_FOLLOW, nil, hCaster:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nTargetFX )

	EmitSoundOn( "Hero_VengefulSpirit.NetherSwap", hCaster )
	EmitSoundOn( "Hero_VengefulSpirit.NetherSwap", hTarget )

	hCaster:StartGesture( ACT_DOTA_CHANNEL_END_ABILITY_4 )
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
