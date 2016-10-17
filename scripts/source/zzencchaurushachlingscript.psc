Scriptname zzEncChaurusHachlingScript extends Actor

event OnLoad()
	self.SetAV("SpeedMult", 150.0 / Self.GetScale() )
endEvent

event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	self.RemoveAllItems()

	if ( self.GetScale() >= 5.0 && !self.HasSpell(crChaurusPoisonSpit01) )
		self.AddSpell( crChaurusPoisonSpit01 )
	endIf
endEvent

SPELL Property crChaurusPoisonSpit01  Auto  
