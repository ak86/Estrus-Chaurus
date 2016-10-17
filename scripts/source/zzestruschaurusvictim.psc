Scriptname zzestruschaurusvictim extends ReferenceAlias  

Quest property zzestrushaurusSpectators auto

Faction property SexlabAnimatingFaction auto

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	int SpectatorRefs = zzestrushaurusSpectators.GetNumAliases()
	while SpectatorRefs > 1
		SpectatorRefs -= 1
		If (zzestrushaurusSpectators.GetNthAlias(SpectatorRefs)  as ReferenceAlias).ForceRefIfEmpty(akAggressor)
			(akAggressor as Actor).stopcombat()
			SpectatorRefs = 0
			endif
	endwhile
EndEvent

Event OnDeath(Actor akKiller)
	self.clear()
EndEvent

Event OnUpdate()
	If Self.GetActorRef().isInFaction(SexlabAnimatingFaction)
		RegisterForSingleUpdate(1)
	else
		Self.clear()
	endif
EndEvent