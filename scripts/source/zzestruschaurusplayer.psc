Scriptname zzEstrusChaurusPlayer extends ReferenceAlias  

event OnPlayerLoadGame()
	Quest me = self.GetOwningQuest()

	( me as zzEstrusChaurusMCMScript ).registerMenus()
	( me as zzEstrusChaurusevents ).InitModEvents()
endEvent

event OnCellLoad()
	Quest me = self.GetOwningQuest()

	if ( me as zzEstrusChaurusMCMScript ).bRegisterCompanions
		( me as zzEstrusChaurusAE ).AddCompanions()
	endIf
endEvent
