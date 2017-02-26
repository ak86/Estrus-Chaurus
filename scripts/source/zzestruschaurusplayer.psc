Scriptname zzEstrusChaurusPlayer extends ReferenceAlias  

event OnPlayerLoadGame()
	Quest me = self.GetOwningQuest()

	( me as zzEstrusChaurusMCMScript ).registerMenus()
	( me as zzEstrusChaurusevents ).InitModEvents()
	( me as zzestruschaurusae ).InitModEvents()
endEvent