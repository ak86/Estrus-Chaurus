Scriptname zzEstrusChaurusPlayer extends ReferenceAlias  

event OnPlayerLoadGame()
	Quest me = self.GetOwningQuest()

	( me as zzEstrusChaurusMCMScript ).registerMenus()
	( me as zzEstrusChaurusevents ).InitModEvents()
	( me as zzestruschaurusae ).InitModEvents()
endEvent

Event OnInit()
	debug.notification("EC+ Installed - Save & reload your game to start...  ")
EndEvent
