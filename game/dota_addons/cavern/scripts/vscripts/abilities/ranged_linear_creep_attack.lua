ranged_linear_creep_attack = class({})

--------------------------------------------------------------------------------

function ranged_linear_creep_attack:OnSpellStart()
	if IsServer() then
		self.attack_speed = self:GetSpecialValueFor( "attack_speed" )
		self.attack_width_initial = self:GetSpecialValueFor( "attack_width_initial" )
		self.attack_width_end = self:GetSpecialValueFor( "attack_width_end" )
		self.attack_distance = self:GetSpecialValueFor( "attack_distance" )
		self.attack_damage = self:GetSpecialValueFor( "attack_damage" ) 

		local vPos = nil
		if self:GetCursorTarget() then
			vPos = self:GetCursorTarget():GetOrigin()
		else
			vPos = self:GetCursorPosition()
		end

		local vDirection = vPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		self.attack_speed = self.attack_speed * ( self.attack_distance / ( self.attack_distance - self.attack_width_initial ) )
		local szEffectName = "particles/base_attacks/ranged_tower_good_linear.vpcf"
		if self:GetCaster():GetTeamNumber() == DOTA_TEAM_BADGUYS then
			szEffectName = "particles/base_attacks/ranged_tower_bad_linear.vpcf"
		end
		local attach = self:GetCaster():ScriptLookupAttachment( "attach_attack1" ) 
		local vPos = self:GetCaster():GetAttachmentOrigin( attach )
	
		local info = {
			EffectName = szEffectName,
			Ability = self,
			vSpawnOrigin = vPos, 
			fStartRadius = self.attack_width_initial,
			fEndRadius = self.attack_width_end,
			vVelocity = vDirection * self.attack_speed,
			fDistance = self.attack_distance,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
		}

		ProjectileManager:CreateLinearProjectile( info )
		EmitSoundOn( "Tower.Water.Attack", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function ranged_linear_creep_attack:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
			local damage = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = self.attack_damage,
				damage_type = self:GetAbilityDamageType(),
				ability = self
			}

			ApplyDamage( damage )
			EmitSoundOn( "Tower.Water.ProjectileImpact", self:GetCaster() )
		end

		return true
	end
end

--------------------------------------------------------------------------------
