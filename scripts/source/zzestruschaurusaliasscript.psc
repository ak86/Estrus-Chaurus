Scriptname zzestruschaurusaliasscript extends ReferenceAlias  

int function minInt(int iA, int iB)
	if iA < iB
		return iA
	else
		return iB
	endIf
endFunction

Float function eggChain()
	ObjectReference[] thisEgg = new ObjectReference[13]
	bool bHasScrotNode        = XPMSELib.HasNode(kTarget, NINODE_GENSCROT)

	Sound.SetInstanceVolume( zzEstrusBreastPainMarker.Play(kTarget), 1.0 )
	Int idx = 0
	Int len = Utility.RandomInt( 5, 9 )
	while idx < len
		thisEgg[idx] = kTarget.PlaceAtme(zzChaurusEggs, abForcePersist = true)
		thisEgg[idx].SetActorOwner( kTarget.GetActorBase() )

			If bHasScrotNode
				thisEgg[idx].MoveToNode(kTarget, NINODE_GENSCROT)
				;thisEgg[idx].SplineTranslateToRefNode(kTarget, NINODE_GENSCROT, 100.0, 0.1)
			else
				thisEgg[idx].MoveToNode(kTarget, NINODE_SKIRT02)
				;thisEgg[idx].SplineTranslateToRefNode(kTarget, NINODE_SKIRT02, 100.0, 0.1)
			endif

		idx += 1
		Utility.Wait( Utility.RandomFloat( 3.5, 6.5 ) )
	endWhile

	return len / 4;(7)
endFunction

function oviposition()
	bool finished = false
	float fReduction
	float fBreastReduction
	float fButtReduction

	; make sure we have 3d loaded to access
	while ( !kTarget.Is3DLoaded() )
		Utility.Wait( 1.0 )
	endWhile
	if ( zzEstrusChaurusUninstall.GetValueInt() == 1 )
		GoToState("AFTERMATH")
		return
	endIf
	
	fReduction       = eggChain()
	fBreastReduction = fReduction / 2.0
	fButtReduction   = fReduction / 2.0
		
	; BELLY SWELL =====================================================
	if ( bBellyEnabled )
		fPregBelly = fPregBelly - fReduction

		if ( fPregBelly <= fOrigBelly )
			fPregBelly = fOrigBelly
		endif
		
		finished = ( fPregBelly == fOrigBelly )
		
		SetNodeScaleBelly(kTarget, bIsFemale, fPregBelly)
	endif
	
	; BUTT SWELL ======================================================
	if ( bButtEnabled )
		fPregButt  = fPregButt  - fButtReduction

		if ( fPregButt <= fOrigButt )
			fPregButt  = fOrigButt
			finished = ( !bBellyEnabled && !bBreastEnabled )
		endif
		
		SetNodeScaleButt(kTarget, bIsFemale, fPregButt)
	endif

	; BREAST SWELL ====================================================
	if ( bBreastEnabled )
		fPregBreast        = fPregBreast - fBreastReduction
		if bTorpedoFixEnabled
			fPregBreast01  = fOrigBreast01 * (fOrigBreast / fPregBreast)
		endIf

		if ( fPregBreast <= fOrigBreast )
			fPregBreast = fOrigBreast
			finished = ( !bBellyEnabled && !bButtEnabled )
		endif

		if bTorpedoFixEnabled
			if ( fPregBreast01 < fOrigBreast01 )
				fPregBreast01  = fOrigBreast01
			endif
		endif
		
		SetNodeScaleBreast(kTarget, bIsFemale, fPregBreast, fPregBreast01)
	endif
	
	if !bBellyEnabled && !bBreastEnabled && !bButtEnabled
		fPregBelly = fPregBelly - fReduction

		finished = ( fPregBelly < fOrigBelly )
	endIf

	Utility.Wait( Utility.RandomFloat( fOviparityTime, fOviparityTime * 2.0 ) )

	if ( !finished && iBirthingLoops > 0 )
		iBirthingLoops -= 1
		oviposition()
	else
		if !finished
			debug.trace("_EC_::Oviposition timed out") 
		endif
		Debug.Trace("_EC_::GTS::AFTERMATH")
		GoToState("AFTERMATH")
	endif
endFunction

function manageSexLabAroused(int aiModRank = -1)
	if !MCM.kfSLAExposure
		return
	endIf
	
	int iRank = kTarget.GetFactionRank(MCM.kfSLAExposure)
	
	if aiModRank == 0 || iOrigSLAExposureRank < -2
		iOrigSLAExposureRank = iRank
	endIf
	if aiModRank < 0
		kTarget.SetFactionRank(MCM.kfSLAExposure, iOrigSLAExposureRank)
	endIf
	if aiModRank > 0 && iRank < 100
		kTarget.ModFactionRank(MCM.kfSLAExposure, minInt(aiModRank, 100 - aiModRank) )
	endIf
endFunction

function triggerNodeUpdate(bool abwait = false)
	iBreastSwellGlobal = zzEstrusSwellingBreasts.GetValueInt()
	iBellySwellGlobal  = zzEstrusSwellingBelly.GetValueInt()
	iButtSwellGlobal   = zzEstrusSwellingButt.GetValueInt()
endFunction

event OnUpdateGameTime()
	int Timer = 5
	while !kTarget.Is3DLoaded() && Timer > 0
		Timer -= 1
		Utility.Wait( 1.0 )
	endWhile

	If kTarget.Is3DLoaded() && kTarget.GetParentCell() == kPlayer.GetParentCell()
		Debug.Trace("_EC_::GTS::BIRTHING")
		GoToState("BIRTHING")
	else
		GoToState("ENDPREGNANCY")
	endif
endEvent

Event OnLoad()
	;debug.Notification("Load event: " + kTarget.GetActorBase().getname())
	GoToState(ActiveState)
EndEvent
	
Event OnUnload()
	;debug.Notification("Unload event: " + kTarget.GetActorBase().getname())
	ActiveState = GetState()
	GoToState("SUSPEND")
EndEvent

bool Function Check3dState() ;Got to Suspend state if 3d cannot be loaded
	If !kTarget.Is3DLoaded() 
		utility.wait(2)
	endif
	If kTarget.Is3DLoaded() && kTarget.GetParentCell() == kPlayer.GetParentCell()
		if Getstate() == "SUSPEND"
			OnLoad()
			;debug.Notification("Check3dState Resume event: " + kTarget.GetActorBase().getname())
		endif
		return true
	Else
		if !Getstate() == "SUSPEND"
			;debug.Notification("Check3dState Suspend event: " + kTarget.GetActorBase().getname())
			OnUnload()
		endif
		Return false
	endif
endFunction

state SUSPEND
	event OnBeginState()
		Debug.Trace("_EC_::state::SUSPEND")
	endEvent

	event OnUpdate()
		Check3dState()
		RegisterForSingleUpdate( fWaitingTime )
	endEvent

	event OnUpdateGameTime()
		;debug.Notification("Suspend EndPregnancy event: " + kTarget.GetActorBase().getname())
		Debug.Trace("_EC_::END OF PREGNANCY WITH NPC UNLOADED - "+ kTarget.GetActorBase().getname())
		GoToState("ENDPREGNANCY")
	endEvent

endState

state IMPREGNATE
	event OnBeginState()
		Debug.Trace("_EC_::state::IMPREGNATE")
	endEvent

	event OnUpdate()
		if ( zzEstrusChaurusUninstall.GetValueInt() == 1 )
			GoToState("AFTERMATH")
		endIf

		if ( !kTarget.IsInFaction( SexLabAnimatingFaction ) )
			; all will be false if bDisableNodeChange is true
			if ( bBellyEnabled || bBreastEnabled || bButtEnabled )
				GoToState("INCUBATION_NODE")
			Else
				GoToState("INCUBATION")
			endif
		endif

		RegisterForSingleUpdate( fWaitingTime )
	endEvent
endState

state INCUBATION_NODE
	event OnBeginState()
		Debug.Trace("_EC_::state::INCUBATION_NODE" )
	endEvent
	
	event OnCellLoad()
		Debug.Trace("_EC_::oncellload" )
		triggerNodeUpdate()
	endEvent

	event OnUpdate()
		if ( zzEstrusChaurusUninstall.GetValueInt() == 1 )
			GoToState("AFTERMATH")
		endIf
		; catch a state change caused by RegisterForSingleUpdate
		if ( GetState() == "INCUBATION_NODE" )
			while ( kTarget.IsOnMount() || Utility.IsInMenuMode() )
				Utility.Wait( 2.0 )
			endWhile
			; make sure we have 3d loaded to access
			if !Check3dState() 
				RegisterForSingleUpdate( fWaitingTime )
				Return
			Endif
			fGameTime       = Utility.GetCurrentGameTime()
			fInfectionSwell = ( fGameTime - fInfectionStart ) / 1.6666 ;1.6666
			fBellySwell     = 0.0
			fBreastSwell    = 0.0
			fButtSwell      = 0.0
			
			; SexLab Aroused ==================================================
			manageSexLabAroused(1)
			
			; BREAST SWELL ====================================================
			iBreastSwellGlobal = zzEstrusSwellingBreasts.GetValueInt()
			if ( bBreastEnabled && iBreastSwellGlobal )
				fBreastSwell       = fInfectionSwell / iBreastSwellGlobal
				fPregBreast        = fOrigBreast + fBreastSwell
				if bTorpedoFixEnabled
					fPregBreast01  = fOrigBreast01 * (fOrigBreast / fPregBreast)
				endIf

				if fInfectionLastMsg < fGameTime && fInfectionSwell > 0.05
					fInfectionLastMsg = fGameTime + Utility.RandomFloat(0.0417, 0.25)
					;Debug.Notification(sSwellingMsgs[Utility.RandomInt(0, sSwellingMsgs.Length - 1)])
					Sound.SetInstanceVolume( zzEstrusBreastPainMarker.Play(kTarget), 1.0 )
				endif

				if ( fPregBreast > NINODE_MAX_SCALE )
					fPregBreast = NINODE_MAX_SCALE
				endif
				if bTorpedoFixEnabled
					if ( fPregBreast01 < NINODE_MIN_SCALE )
						fPregBreast01 = NINODE_MIN_SCALE
					endif
				endif
				if ( fPregBreast > zzEstrusChaurusMaxBreastScale.GetValue() )
					fPregBreast = zzEstrusChaurusMaxBreastScale.GetValue()
				endif

				kTarget.SetAnimationVariableFloat("ecBreastSwell", fBreastSwell)
				SetNodeScaleBreast(kTarget, bIsFemale, fPregBreast, fPregBreast01)
			elseIf ( bBreastEnabled && fPregBreast != fOrigBreast )
				fPregBreast    = fOrigBreast
				if bTorpedoFixEnabled
					fPregBreast01  = fOrigBreast01
				endIf
				
				kTarget.SetAnimationVariableFloat("ecBreastSwell", 0.0)
				SetNodeScaleBreast(kTarget, bIsFemale, fPregBreast, fPregBreast01)
			endif

			; BELLY SWELL =====================================================
			iBellySwellGlobal = zzEstrusSwellingBelly.GetValueInt()
			if ( bBellyEnabled && iBellySwellGlobal )
				
				if iBellySwellGlobal == 1   ;fBellySwell = fInfectionSwell / iBellySwellGlobal
					fBellySwell = (fInfectionSwell / iBellySwellGlobal) * 2 
				else
					fBellySwell = fInfectionSwell / iBellySwellGlobal
				endif
				fPregBelly  = fOrigBelly + fBellySwell
				if fInfectionLastMsg < fGameTime && fInfectionSwell > 0.05
					fInfectionLastMsg = fGameTime + Utility.RandomFloat(0.0417, 0.25)
					Sound.SetInstanceVolume( zzEstrusBreastPainMarker.Play(kTarget), 1.0 )
				endif

				if ( fPregBelly > NINODE_MAX_SCALE * 2.0 ) 
					fPregBelly = NINODE_MAX_SCALE * 2.0 
				endif
				if ( fPregBelly > zzEstrusChaurusMaxBellyScale.GetValue() )
					fPregBelly = zzEstrusChaurusMaxBellyScale.GetValue()
				endif

				kTarget.SetAnimationVariableFloat("ecBellySwell", fBellySwell)
				SetNodeScaleBelly(kTarget, bIsFemale, fPregBelly)
			elseIf ( bBellyEnabled && fPregBelly != fOrigBelly )
				fPregBelly = fOrigBelly
				kTarget.SetAnimationVariableFloat("ecBellySwell", 0.0)
				SetNodeScaleBelly(kTarget, bIsFemale, fPregBelly)
			endif

			; BUTT SWELL ======================================================
			iButtSwellGlobal = zzEstrusSwellingButt.GetValueInt()
			if ( bButtEnabled && iButtSwellGlobal )
				fButtSwell = fInfectionSwell / iButtSwellGlobal
				fPregButt  = fOrigButt  + fButtSwell

				if fInfectionLastMsg < fGameTime && fInfectionSwell > 0.05
					fInfectionLastMsg = fGameTime + Utility.RandomFloat(0.0417, 0.25)
					Sound.SetInstanceVolume( zzEstrusBreastPainMarker.Play(kTarget), 1.0 )
				endif

				if ( fPregButt > NINODE_MAX_SCALE )
					fPregButt = NINODE_MAX_SCALE 
				endif
				if ( fPregButt > zzEstrusChaurusMaxButtScale.GetValue() )
					fPregButt = zzEstrusChaurusMaxButtScale.GetValue()
				endif

				SetNodeScaleButt(kTarget, bIsFemale, fPregButt)
			elseIf ( bButtEnabled && fPregButt != fOrigButt )
				fPregButt = fOrigButt
				SetNodeScaleButt(kTarget, bIsFemale, fPregButt)
			endif

			kTarget.SetFactionRank(zzEstrusChaurusBreederFaction, Math.Floor(fBellySwell + fBreastSwell) )
			RegisterForSingleUpdate( fUpdateTime )
		endif
	endEvent
endState

state INCUBATION
	event OnBeginState()
		fOrigBelly = 1.0
		fPregBelly = NINODE_MAX_SCALE * 2.0
		Debug.Trace("_EC_::state::INCUBATION")
	endEvent

	event OnUpdate()
		if ( zzEstrusChaurusUninstall.GetValueInt() == 1 )
			GoToState("AFTERMATH")
		endIf

		; catch a state change caused by RegisterForSingleUpdate
		if ( GetState() == "INCUBATION" )
			; SexLab Aroused ==================================================
			manageSexLabAroused(1)

			RegisterForSingleUpdate( fUpdateTime )
		endif
	endEvent
endState

state BIRTHING
	event OnBeginState()
		Debug.Trace("_EC_::state::BIRTHING")
		while ( kTarget.IsOnMount() || Utility.IsInMenuMode() )
			Utility.Wait( 2.0 )
		endWhile

		if kTarget.IsWeaponDrawn()
			kTarget.SheatheWeapon()
		endIf		
		;Debug.SendAnimationEvent(kTarget, "BleedOutStart")
		stripActor(kTarget)
		Debug.SendAnimationEvent(kTarget, "IdleBedRollFrontEnterStart")
		Utility.Wait( 10.0 )
		;iAnimationIndex += 1
		;Debug.SendAnimationEvent(kTarget, "Arrok_Missionary_A1_S"+iAnimationIndex)
		Debug.SendAnimationEvent(kTarget, "zzEstrusCommon01Up")
		bIsAnimating = true

		if ( MCM.zzEstrusChaurusBirth.GetValueInt() == 1 )
			iBirthingLoops = 1
		else
			iBirthingLoops = 3
		endif

		if bIsFemale && MCM.zzEstrusChaurusFluids.GetValue() as bool
			;kTarget.AddItem(zzEstrusChaurusFluid, 1, true)
			kTarget.EquipItem(zzEstrusChaurusFluid, true, true)
			;kTarget.AddItem(zzEstrusChaurusMilkR, 1, true)
			kTarget.EquipItem(zzEstrusChaurusRMilk, true, true)
			;kTarget.AddItem(zzEstrusChaurusMilkL, 1, true)
			kTarget.EquipItem(zzEstrusChaurusLMilk, true, true)
		endIf
		
		if ( MCM.zzEstrusChaurusResidual.GetValueInt() == 1 )
			float fResidualScale = MCM.zzEstrusChaurusResidualScale.GetValue()

			fResiBreast  = fOrigBreast * fResidualScale
			if bTorpedoFixEnabled
				fOrigBreast01  = (fOrigBreast / fResiBreast)
			endIf
			fOrigBreast  = fResiBreast
		endIf
		
		if kTarget == kPlayer
			Game.ForceThirdPerson()
			Game.SetPlayerAIDriven()
		else
			kTarget.SetRestrained(true)
			kTarget.SetDontMove(true)
		endIf
		oviposition()
	endEvent

	event OnUpdate()
		; catch any pending updates
	endEvent
endState

state AFTERMATH
	event OnBeginState()
		Debug.Trace("_EC_::state::AFTERMATH")

		if bIsFemale
			;kTarget.UnequipItem(zzEstrusChaurusFluid, false, true)
			kTarget.RemoveItem(zzEstrusChaurusFluid, 1, true)
			;kTarget.UnequipItem(zzEstrusChaurusMilkR, false, true)
			kTarget.RemoveItem(zzEstrusChaurusRMilk, 1, true)
			;kTarget.UnequipItem(zzEstrusChaurusMilkL, false, true)
			kTarget.RemoveItem(zzEstrusChaurusLMilk, 1, true)
		endIf

		if kTarget == kPlayer
			Game.SetPlayerAIDriven(false)
		else
			kTarget.SetRestrained(false)
			kTarget.SetDontMove(false)
		endIf

		if bIsAnimating
			Debug.SendAnimationEvent(kTarget, "zzEstrusGetUpFaceUp")
		endIf

		;Debug.SendAnimationEvent(kTarget, "zzEstrusGetUpFaceUp")
		;Debug.SendAnimationEvent(kTarget, "BleedOutStop")
		OnBreederFinish()
	
		SendModEvent("ECBirthCompleted") ;as requested by Skyrimll

	endEvent

	event OnUpdate()
		; catch any pending updates
	endEvent
endState

state ENDPREGNANCY
	event OnBeginState()
		Debug.Trace("_EC_::state::ENDPREGNANCY")

		;Debug.SendAnimationEvent(kTarget, "BleedOutStop")
		OnBreederFinish()
	endEvent

	event OnUpdate()
		; catch any pending updates
	endEvent

endState

event OnBreederStart(Actor akTarget, Int akIncubationIdx)
	
	iIncubationIdx = akIncubationIdx
	
	kTarget            = akTarget
	kPlayer            = Game.GetPlayer()
	bDisableNodeChange = zzEstrusDisableNodeResize.GetValue() as Bool
	bIsAnimating	   = false
	
	;sSwellingMsgs      = new String[3]
	;sSwellingMsgs[0]   = "$EC_SWELLING_1_3RD"
	;sSwellingMsgs[1]   = "$EC_SWELLING_2_3RD"
	;sSwellingMsgs[2]   = "$EC_SWELLING_3_3RD"


	GoToState("IMPREGNATE")
	zzEstrusChaurusInfected.Mod( 1.0 )
	kTarget.StopCombatAlarm()

	Float fMinTime     = zzEstrusIncubationPeriod.GetValue() * fIncubationTimeMin
	Float fMaxTime     = zzEstrusIncubationPeriod.GetValue() * fIncubationTimeMax
	fIncubationTime    = Utility.RandomFloat( fMinTime, fMaxTime )
	fInfectionStart    = Utility.GetCurrentGameTime()
	fthisIncubation    = fInfectionStart + ( fIncubationTime / 24.0 )
	bIsFemale          = kTarget.GetLeveledActorBase().GetSex() == 1
	bTorpedoFixEnabled = zzEstrusChaurusTorpedoFix.GetValueInt() as Bool

	;kCaster.PathToReference(kTarget, 1.0)

	kTarget.AddToFaction(zzEstrusChaurusBreederFaction)
	
	;iIncubationIdx = Self.GetID() ;MCM.kIncubationDue.Find(kTarget, 1)
	;if iIncubationIdx > 0
	MCM.fIncubationDue[iIncubationIdx] = fthisIncubation
	MCM.kIncubationDue[iIncubationIdx] = kTarget
	
			;(EC.GetNthAlias(iIncubationIdx) as ReferenceAlias).ForceRefTo(kTarget)
		;else
			;self.Clear()
			;return
		;endif

	; SexLab Aroused
	manageSexLabAroused(0)
	
	if CheckXPMSERequirements(kTarget, bIsFemale)
		bEnableSkirt02     = true
		bEnableSkirt03     = true
		bEnableBreast      = true
		bEnableButt        = true
		bEnableBelly       = true
	else
		bEnableSkirt02     = XPMSELib.HasNode(kTarget, NINODE_SKIRT02)
		bEnableSkirt03     = XPMSELib.HasNode(kTarget, NINODE_SKIRT03)
		bEnableBreast      = XPMSELib.HasNode(kTarget, NINODE_LEFT_BREAST) && XPMSELib.HasNode(kTarget, NINODE_RIGHT_BREAST)
		bEnableButt        = XPMSELib.HasNode(kTarget, NINODE_LEFT_BUTT) && XPMSELib.HasNode(kTarget, NINODE_RIGHT_BUTT)
		bEnableBelly       = XPMSELib.HasNode(kTarget, NINODE_BELLY)
	endif
	
	if ( !bDisableNodeChange )
		If !Check3dState()
			Registerforsingleupdate(fWaitingTime)
			return
		endIf
		bBreastEnabled     = ( bEnableBreast && zzEstrusSwellingBreasts.GetValueInt() as bool )
		bButtEnabled       = ( bEnableButt && zzEstrusSwellingButt.GetValueInt() as bool )
		bBellyEnabled      = ( bEnableBelly && zzEstrusSwellingBelly.GetValueInt() as bool )

		if ( bBreastEnabled && kTarget.GetLeveledActorBase().GetSex() == 1 )
			fOrigBreast  = GetNodeTransformScale(kTarget, bIsFemale, NINODE_LEFT_BREAST)
			if bTorpedoFixEnabled
				fOrigBreast01  = GetNodeTransformScale(kTarget, bIsFemale, NINODE_LEFT_BREAST01)
			endif
		endif
		if ( bButtEnabled )
			fOrigButt    = GetNodeTransformScale(kTarget, bIsFemale, NINODE_LEFT_BUTT)
		endif
		if ( bBellyEnabled )
			fOrigBelly       = GetNodeTransformScale(kTarget, bIsFemale, NINODE_BELLY)
		endif
	endif

	if bEnableSkirt02
		RegisterForSingleUpdate( fUpdateTime )
		RegisterForSingleUpdateGameTime( fIncubationTime )
	Else
		Debug.MessageBox("$EC_INCOMPATIBLE")
		kTarget.RemoveSpell(zzEstrusChaurusBreederAbility)
	endif
endEvent

event OnBreederFinish()
	zzEstrusChaurusInfected.Mod( -1.0 )
	bUninstall = zzEstrusChaurusUninstall.GetValueInt() as Bool

	if iIncubationIdx != -1
		MCM.fIncubationDue[iIncubationIdx] = 0.0
		MCM.kIncubationDue[iIncubationIdx] = None
	endIf

	if ( kTarget.IsInFaction(zzEstrusChaurusBreederFaction) )
		kTarget.RemoveFromFaction(zzEstrusChaurusBreederFaction)
	endIf

	; if we are uninstalling, report the first 128 infected NPCs
	if ( bUninstall )
		iIncubationIdx = MCM.kIncubationOff.Find(none)
		if ( iIncubationIdx >= 0 )
			MCM.kIncubationOff[iIncubationIdx] = kTarget
		endif
	endIf
	
	; SexLab Aroused
	manageSexLabAroused()

	if ( !bDisableNodeChange )
		; make sure we have loaded 3d to access

		while ( kTarget.IsOnMount() || Utility.IsInMenuMode() )
			Utility.Wait( 1.0 )
		endWhile

		if ( bBellyEnabled )
			SetNodeScaleBelly(kTarget, bIsFemale, fOrigBelly)
		endif

		if ( bButtEnabled )
			SetNodeScaleButt(kTarget, bIsFemale, fOrigButt)
		endif

		if ( bBreastEnabled )
			SetNodeScaleBreast(kTarget, bIsFemale, fOrigBreast, fOrigBreast01)
		endif
		
		if !kTarget.Is3DLoaded() ;******************************
			triggerNodeUpdate(true)
		endif

	endif
			
	Self.Clear()

endEvent


function stripActor(actor akVictim)

	Form ItemRef = None
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(30))
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(31))
	;StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(32))
	StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(33))
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(34))
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(37)) #You can keep your boots on!#
	;StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(38))
	;StripItem(akVictim, ItemRef)	
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(39))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetEquippedWeapon(false)
	if ItemRef
		akVictim.UnequipItemEX(ItemRef, 1, false)
	endIf
	ItemRef = akVictim.GetEquippedWeapon(true)
	if ItemRef
		akVictim.UnequipItemEX(ItemRef, 2, false)
	endif
endfunction

function StripItem(actor akVictim, form ItemRef)
	If ItemRef
		Armor akArmor = ItemRef as Armor
		akVictim.UnequipItem(ItemRef, false, true)
	endif
endfunction

Function SetNodeScaleBelly(Actor akActor, bool isFemale, float value)
	XPMSELib.SetNodeScale(akActor, isFemale, NINODE_BELLY, value, EC_KEY)
EndFunction

Function SetNodeScaleButt(Actor akActor, bool isFemale, float value)
	XPMSELib.SetNodeScale(akActor, isFemale, NINODE_LEFT_BUTT, value, EC_KEY)
	XPMSELib.SetNodeScale(akActor, isFemale, NINODE_RIGHT_BUTT, value, EC_KEY)
EndFunction

Function SetNodeScaleBreast(Actor akActor, bool isFemale, float value, float value01)
	XPMSELib.SetNodeScale(akActor, isFemale, NINODE_LEFT_BREAST, value, EC_KEY)
	XPMSELib.SetNodeScale(akActor, isFemale, NINODE_RIGHT_BREAST, value, EC_KEY)
	if bTorpedoFixEnabled
		XPMSELib.SetNodeScale(akActor, isFemale, NINODE_LEFT_BREAST01, value01, EC_KEY)
		XPMSELib.SetNodeScale(akActor, isFemale, NINODE_RIGHT_BREAST01, value01, EC_KEY)
	endIf
EndFunction

float Function GetNodeTransformScale(Actor akActor, bool isFemale, string nodeName)
	return NiOverride.GetNodeTransformScale(akActor, false, isFemale, nodeName, EC_KEY)
EndFunction

bool Function CheckXPMSERequirements(Actor akActor, bool isFemale)
	return Game.GetModByName("CharacterMakingExtender.esp") == 255 && XPMSELib.CheckXPMSEVersion(akActor, isFemale, XPMSE_VERSION, true) && XPMSELib.CheckXPMSELibVersion(XPMSELIB_VERSION) && SKSE.GetPluginVersion("NiOverride") >= NIOVERRIDE_VERSION && NiOverride.GetScriptVersion() >= NIOVERRIDE_SCRIPT_VERSION
EndFunction

Actor kTarget  			 = None
Actor kCaster            = None
Actor kPlayer            = None
Bool  bDisableNodeChange = False
Bool  bEnableBreast      = False
Bool  bEnableButt        = False
Bool  bEnableBelly       = False
Bool  bEnableSkirt02     = False
Bool  bEnableSkirt03     = False
Bool  bBreastEnabled     = False
Bool  bButtEnabled       = False
Bool  bBellyEnabled      = False
Bool  bUninstall         = False
Bool  bIsFemale          = False
Bool  bTorpedoFixEnabled = True
Float fOrigBreast        = 1.0
Float fPregBreast        = 1.0
Float fResiBreast        = 1.0
Float fOrigBreast01      = 1.0
Float fPregBreast01      = 1.0
Float fOrigButt      = 1.0
Float fPregButt          = 1.0
Float fOrigBelly         = 1.0
Float fPregBelly         = 1.0
Float fInfectionStart    = 0.0
Float fInfectionSwell    = 0.0
Float fInfectionLastMsg  = 0.0
Float fBreastSwell       = 0.0
Int   iBreastSwellGlobal = 0
Float fButtSwell         = 0.0
Int   iButtSwellGlobal   = 0
Float fBellySwell        = 0.0
Int   iBellySwellGlobal  = 0
Float fUpdateTime        = 5.0
Float fWaitingTime       = 10.0
Float fOviparityTime     = 7.5
; * zzEstrusIncubationPeriod ( days )
Float fIncubationTimeMin = 22.6
Float fIncubationTimeMax = 26.6
Float fthisIncubation    = 0.0
Float fGameTime          = 0.0
Int iIncubationIdx       = -1
Int iBirthingLoops       = 3
; SexLab Aroused
Int iOrigSLAExposureRank = -3
Int iAnimationIndex      = 1
bool bIsAnimating		 = false

String[] sSwellingMsgs
String ActiveState

Quest				     Property EC                             Auto
zzEstrusChaurusMCMscript Property MCM                            Auto 

Armor                    Property zzEstrusChaurusFluid           Auto
Armor                    Property zzEstrusChaurusRMilk           Auto
Armor                    Property zzEstrusChaurusLMilk           Auto
Faction                  Property CurrentFollowerFaction         Auto
Faction                  Property zzEstrusChaurusBreederFaction  Auto
Faction                  Property SexLabAnimatingFaction         Auto
GlobalVariable           Property zzEstrusDisableNodeResize      Auto
GlobalVariable           Property zzEstrusIncubationPeriod       Auto
GlobalVariable           Property zzEstrusSwellingBreasts        Auto
GlobalVariable           Property zzEstrusSwellingBelly          Auto
GlobalVariable           Property zzEstrusSwellingButt           Auto
GlobalVariable           Property zzEstrusChaurusUninstall       Auto
GlobalVariable           Property zzEstrusChaurusInfected        Auto
GlobalVariable           Property zzEstrusChaurusMaxBreastScale  Auto  
GlobalVariable           Property zzEstrusChaurusMaxBellyScale   Auto
GlobalVariable           Property zzEstrusChaurusMaxButtScale    Auto
GlobalVariable           Property zzEstrusChaurusTorpedoFix      Auto  
Ingredient               Property zzChaurusEggs                  Auto
Spell                    Property zzEstrusChaurusBreederAbility  Auto
Sound                    Property zzEstrusBreastPainMarker       Auto
Static                   Property xMarker                        Auto
Float                    Property fIncubationTime                Auto

string                   Property EC_KEY                = "Estrus_Chaurus" AutoReadOnly
String                   Property NINODE_LEFT_BREAST    = "NPC L Breast" AutoReadOnly
String                   Property NINODE_LEFT_BREAST01  = "NPC L Breast01" AutoReadOnly
String                   Property NINODE_LEFT_BUTT      = "NPC L Butt" AutoReadOnly
String                   Property NINODE_RIGHT_BREAST   = "NPC R Breast" AutoReadOnly
String                   Property NINODE_RIGHT_BREAST01 = "NPC R Breast01" AutoReadOnly
String                   Property NINODE_RIGHT_BUTT     = "NPC R Butt" AutoReadOnly
String                   Property NINODE_SKIRT02        = "SkirtBBone02" AutoReadOnly
String                   Property NINODE_SKIRT03        = "SkirtBBone03" AutoReadOnly
String                   Property NINODE_BELLY          = "NPC Belly" AutoReadOnly
String                   Property NINODE_PELVIS         = "NPC Pelvis [Pelv]" AutoReadOnly
String                   Property NINODE_GENSCROT       = "NPC GenitalsScrotum [GenScrot]" AutoReadOnly
String                   Property NINODE_EGG            = "Egg:0" AutoReadOnly
Float                    Property NINODE_MAX_SCALE      = 3.0 AutoReadOnly
Float                    Property NINODE_MIN_SCALE      = 0.1 AutoReadOnly

; NiOverride version data
int                      Property NIOVERRIDE_VERSION    = 4 AutoReadOnly
int                      Property NIOVERRIDE_SCRIPT_VERSION = 4 AutoReadOnly

; XPMSE version data
float                    Property XPMSE_VERSION         = 3.0 AutoReadOnly
float                    Property XPMSELIB_VERSION      = 3.0 AutoReadOnly
