Scriptname zzestruschaurusspectator extends ReferenceAlias  

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	actor Spectator = self.GetReference() as Actor
	if Spectator != None && !Spectator.isDead()
		if !(akAggressor as actor).isDead()
			Spectator.StartCombat(akAggressor as actor)
		endif
	endif
	self.clear()
EndEvent

Event OnDeath(Actor akKiller)
	self.clear()
EndEvent