Scriptname zzEstrusChaurusDwemerTrap extends ObjectReference  

SexLabFramework    property SexLab  auto
zzEstrusChaurusAE  property me      auto

sslBaseAnimation[] animations
Actor[]            sexActors


event OnTriggerEnter( objectReference triggerRef )
;event OnActivate( objectReference triggerRef )
	Actor kActivator = triggerRef as Actor
	
	Debug.Notification("\n\n===================================>" + kActivator + "\n\n")
	
	if SexLab.ValidateActor(kActivator) && kActivator.HasKeyword(me.ActorTypeNPC)
		animations   = SexLab.GetAnimationsByTag(1, "Dwemer", "Machine")
		sexActors    = new actor[1]
		sexActors[0] = kActivator
		
		me.RegisterForModEvent("AnimationStart_estrusChaurus", "estrusChaurusStart")
		me.RegisterForModEvent("AnimationEnd_estrusChaurus",   "estrusChaurusEnd")
		me.RegisterForModEvent("StageEnd_estrusChaurus",       "estrusChaurusStage")

		SexLab.StartSex(sexActors, animations, Victim=kActivator, centerOn=self.GetLinkedRef(), hook="estrusChaurus")
	endif
endEvent
