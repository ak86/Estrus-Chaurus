Scriptname zzestruschaurusevents extends Quest

zzEstrusChaurusMCMScript  property mcm Auto

SexLabFramework  property SexLab Auto

Actor[] sexActors

sslBaseAnimation[] animations

faction property ECTentaclefaction Auto
faction property ECVictimfaction Auto
faction property zzEstrusChaurusExclusionFaction  auto
faction property zzEstrusChaurusBreederFaction auto

armor   property zzEstrusChaurusDwemerBinders  auto
armor   property zzEstrusChaurusDwemerBelt  auto
armor  property zzEstrusChaurusParasite auto 

spell property zzEstrusChaurusBreederAbility auto
spell property crChaurusParasite  auto 
spell property DwemerExhaustion Auto

explosion property TentacleExplosion Auto

sound Property zzEstrusTentacleFX Auto
sound property zzEstrusChaurusVibrate Auto

Quest property SpectatorControl Auto

Actor[] Spectator
int SpectatorCount = 0

Keyword property zzEstrusChaurusArmor Auto
Keyword ECpkg = None

int EventFxID0 = 0
int EventFxID1 = 0

bool dDLoaded = false

zadlibs dDlibs = None



;************************************
;**Estrus Chaurus Public Interface **
;************************************
;
;The EC interface uses ModEvents.  This method can be used without loading EC as a master or using GetFormFromFile
; 
;To call an EC event use the following code:
;
; 	int ECTrap = ModEvent.Create("ECStartAnimation"); Int 			Does not have to be named "ECTrap" any name would do
;	if (ECTrap)	
;   	ModEvent.PushForm(ECTrap, self)             ; Form			Some SendModEvent scripting "black magic" - required
;   	ModEvent.PushForm(ECTrap, game.getplayer()) ; Form	 		The animation target
;   	ModEvent.PushInt(ECTrap, EstrusTraptype)    ; Int			The animation required    0 = Tentacles, 1 = Machine
;   	ModEvent.PushBool(ECTrap, true)             ; Bool			Apply the linked EC effect (Ovipostion for Tentacles, Exhaustion for Machine) 
;   	ModEvent.Pushint(ECTrap, 500)               ; Int			Alarm radius in units (0 to disable) 
;   	ModEvent.PushBool(ECTrap, true)             ; Bool			Use EC (basic) crowd control on hostiles 
;   	ModEvent.Send(ECtrap)
;	else
;		;EC is not installed
;	endIf
;
;
;************************************
; Please do not link directly to EC functions - they are likely to change and break your mod!

function InitModEvents()

	RegisterForModEvent("ECStartAnimation", "OnECStartAnimation")
	
	if mcm.kwDeviousDevices != None && !dDLoaded
		dDlibs = Game.GetFormFromFile(0x0000F624, "Devious Devices - Integration.esm") as Zadlibs
		if dDlibs != None
			debug.trace("_EC_::Loaded dD Integration")
			dDLoaded = true
		else
			debug.trace("_EC_::Devious Devices - Integration.esm not found - Devices will not be supported")
			dDLoaded = false
		endif
	endif 

endFunction


bool function OnECStartAnimation(Form Sender, form akTarget, int intAnim, bool bUseFX, int intUseAlarm, bool bUseCrowdControl)

	actor akActor  = akTarget as Actor
	Bool bGenderOk = mcm.zzEstrusChaurusGender.GetValueInt() == 2 || akActor.GetLeveledActorBase().GetSex() == mcm.zzEstrusChaurusGender.GetValueInt()
	Bool invalidateVictim = !bGenderOk || akActor.IsInFaction(zzEstrusChaurusExclusionFaction) || akActor.IsBleedingOut() || akActor.isDead()

	if !invalidateVictim && SexLab.ValidateActor(akActor) == 1

		DoECAnimation(akActor, intAnim, bUseFX, intUseAlarm, bUseCrowdControl)
		
		return true

	else
		
		return false
		
	endIf	

endfunction



function DoECAnimation(actor akVictim, int AnimID, bool UseFX, int UseAlarm, bool UseCrowdControl)

		Spectator = New Actor[20]
		SpectatorCount = 0
		bool isPlayer = (akVictim == game.getplayer())
		string EstrusType
		string strVictimRefid = akVictim.getformid() as string

		int EstrusID = AnimID

		If EstrusID == 1
			EstrusType = "Dwemer"
		Else
			EstrusType = "Tentacle"
		Endif

		armor dDArmbinder = none

		if dDLoaded

			dDArmbinder = dDlibs.GetWornDeviceFuzzyMatch(akVictim, dDlibs.zad_DeviousArmbinder) 

			if akVictim.WornHasKeyword(dDlibs.zad_DeviousBelt)
				if isPlayer
					if EstrusID == 1 
						debug.notification("A red dot scans over your devious devices and vanishes...")
					else
						debug.notification("Something nasty was warded away by your devious aura...")
					endIf
						if UseAlarm
							akvictim.CreateDetectionEvent(akVictim, UseAlarm)
						endif
					return
				endif
			endif
		endif

		if isplayer
			SendModEvent("dhlp-Suspend") ;EC Scene starting - suspend Deviously Helpless Events
		endif 
		
		akVictim.StopCombatAlarm()
		akVictim.StopCombat()
	
		animations   = SexLab.GetAnimationsByTag(1, "Estrus", EstrusType)
		sexActors    = new actor[1]
		sexActors[0] = akVictim
		RegisterForModEvent("AnimationStart_" + strVictimRefid, "ECAnimStart")
		If UseFX
			RegisterForModEvent("StageEnd_" + strVictimRefid, "ECAnimStage")
		Endif
		RegisterForModEvent("AnimationEnd_" + strVictimRefid,   "ECAnimEnd")
		If dDArmbinder
			if isPlayer
				debug.notification("'Something' behind you deftly strips off your armbinder...")
				utility.wait(1)
			endIf
			dDlibs.ManipulateGenericDevice(akVictim, dDArmbinder, false)
			akVictim.DropObject(dDArmbinder, 1)
		Endif

		if UseFX && EstrusID == 0
			akvictim.placeatme(TentacleExplosion)
			if !isPlayer
				akvictim.pushactoraway(akVictim, 2)
				utility.wait(1)
			endif
		endif

		if isplayer && UseCrowdControl
			RegisterForUpdate(2)
		endif

		akVictim.AddToFaction(ECVictimfaction)
		
		if UseAlarm
			akVictim.CreateDetectionEvent(akVictim, UseAlarm)
		endif

		SexLab.StartSex(sexActors, animations, akVictim, none, false, strVictimRefid)

endFunction

event ECAnimStart(string hookName, string argString, float argNum, form sender)
	
	actor[] actorList = SexLab.HookActors(argString)
	sslBaseAnimation animation = SexLab.HookAnimation(argString)
	string strVictimRefid = actorList[0].getformid() as string
	bool isPlayer = (actorlist[0] == game.getplayer())
	armor zzEstrusArmorItem = none

	actorList[0].RestoreActorValue("health", 10000)

	if animation.hastag("Machine") ;********************************************apply generic armor item "binders" ?
		
		if animation.name == "Dwemer Machine"
			zzEstrusArmorItem = zzEstrusChaurusDwemerBinders
		else
			zzEstrusArmorItem = zzEstrusChaurusDwemerBelt
		endif

		utility.wait(0.3)
		if isplayer
			actorList[0].EquipItem(zzEstrusArmorItem, true, true)
			actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches 
			utility.wait(5)
			EventFxID0 = zzEstrusChaurusVibrate.Play(actorList[0]) 
		else	
			actorList[0].EquipItem(zzEstrusArmorItem, true, true)
			actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches 
			stripFollower(actorList[0])
			if EventFxID1 == 0
				EventFxID1 = zzEstrusChaurusVibrate.Play(actorList[0]) 
			endif
		endif
	elseif animation.name == "Tentacle Side"
		utility.wait(5)
		if isplayer
			actorList[0].EquipItem(zzEstrusChaurusParasite, true, true)
		else	
			actorList[0].EquipItem(zzEstrusChaurusParasite, true, true)
			stripFollower(actorList[0])
		endif
		actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches
	endif
endevent

event ECAnimStage(string hookName, string argString, float argNum, form sender)
	
	int stage = SexLab.HookStage(argString)
	actor[] actorList = SexLab.HookActors(argString)
	bool isPlayer = (actorlist[0] == game.getplayer())
	sslBaseAnimation animation = SexLab.HookAnimation(argString)
	armor ECArmor = none

	if animation.hastag("Tentacle") 
		if stage >= 2 && stage < 9 
			SexLab.ApplyCum(actorlist[0], 5)
		endif
		
		if stage < 9
			if isplayer && !EventFxID0 
				EventFxID0 = zzEstrusTentacleFX.Play(actorList[0])
			elseif !isplayer && !EventFxID1
				EventFxID1 = zzEstrusTentacleFX.Play(actorList[0])
			endif
		endif

		;if stage == 9 &&  animation.name == "Tentacle Side"
			;actorlist[0].RemoveItem(zzEstrusChaurusParasite, 1, true)
			;actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches 
			;if !isPlayer
				;stripFollower(actorlist[0])
			;endif
		;endif

		if stage == 7
			Oviposition(actorlist[0])
		endIf
	elseif animation.hastag("Machine")
		if stage == 3
			if isPlayer
				debug.notification("You are losing control...")
			endif
		elseif stage == 5
			if isPlayer
				debug.notification("You begin to orgasm uncontrollably...")
			endif
			SexLab.ApplyCum(actorlist[0], 5)
		elseif stage == 8
			DwemerExhaustion.RemoteCast(actorlist[0],actorlist[0],actorlist[0])
			if isPlayer
				debug.notification("The machine absorbs your sexual energy...")
			endif
		;elseif stage == 9
			;actorlist[0].RemoveItem(zzEstrusChaurusDwemerBinders, 1, true)
			;actorList[0].QueueNiNodeUpdate()  ;Hopefully fix equip visual glitches 
			;if !isPlayer
				;stripFollower(actorlist[0])
			;endif
		elseif stage == 10
			if isPlayer
				debug.notification("You have been forced to orgasm until exhausted...")
			endif
		elseif stage == 11
			if isPlayer
				debug.notification("You are almost too weak to stand...")
			endif
		endif
	endif
	
	if stage > 8 ;Safety Check for active sounds and Estrus Armor at each stage >8 to allow for stage interrupts/lag
		
		if actorlist[0].WornHasKeyword(zzEstrusChaurusArmor)
			if  animation.name == "Tentacle Side"
				ECArmor = zzEstrusChaurusParasite
			else
				if animation.name == "Dwemer Machine"
					ECArmor = zzEstrusChaurusDwemerBinders
				else
					ECArmor = zzEstrusChaurusDwemerBelt
				endif
			endif
			actorList[0].RemoveItem(ECArmor, 1, true) ;*********************************************or - clear slot?
			if !isplayer
				stripFollower(actorList[0])
			endif
		endif

		if !isPlayer && EventFxID1 > 0
			Sound.StopInstance(EventFxID1)
			EventFxID1 = 0
		elseif EventFxID0 >0
			Sound.StopInstance(EventFxID0)
			EventFxID0 = 0
		endif
	endif
endevent

event ECAnimEnd(string hookName, string argString, float argNum, form sender)
	
	actor[] actorList = SexLab.HookActors(argString)
	sslBaseAnimation animation = SexLab.HookAnimation(argString)
	unregisterforupdate()
	string strVictimRefid = actorList[0].getformid() as string
	unregisterformodevent("StageEnd_" + strVictimRefid)
	armor ECArmor = none
	
	int stage = SexLab.HookStage(argString)
	
	bool isPlayer = (actorlist[0] == game.getplayer())
	
	if animation.hastag("Tentacle") 
		actorList[0].DispelSpell(crChaurusParasite)
	endif

	if actorlist[0].WornHasKeyword(zzEstrusChaurusArmor)
		if  animation.name == "Tentacle Side"
			ECArmor = zzEstrusChaurusParasite
		else
			ECArmor = zzEstrusChaurusDwemerBinders
		endif
		actorList[0].RemoveItem(ECArmor, 1, true)
	endif

	SpectatorControl.stop()

	actorList[0].removefromFaction(ECVictimfaction)

	while SpectatorCount > 0
		SpectatorCount -= 1
		Spectator[SpectatorCount].removefromFaction(ECTentaclefaction)
	endwhile

	if !isPlayer && EventFxID1 > 0 ;Sound failsafe for stage skipping sound bug
		Sound.StopInstance(EventFxID1)
		EventFxID1 = 0
	elseif EventFxID0 >0
		Sound.StopInstance(EventFxID0)
		EventFxID0 = 0
	endif
	unregisterformodevent("AnimationStart_" + strVictimRefid)
	unregisterformodevent("AnimationEnd_" + strVictimRefid)

	if isplayer
		SendModEvent("dhlp-Resume") ;Resume Deviously Helpless Events
	else
		Debug.SendAnimationEvent(actorlist[0], "IdleForceDefaultState");Prevent "AI Frozen" Followers
	endif

endevent

Function Oviposition(actor akVictim)
	if ( !akVictim.IsInFaction(zzEstrusChaurusBreederFaction) )
		akVictim.AddToFaction(zzEstrusChaurusBreederFaction)
	endIf
	if ( !akVictim.HasSpell(zzEstrusChaurusBreederAbility ) );
		akVictim.AddSpell(zzEstrusChaurusBreederAbility , false)
	endIf	
	crChaurusParasite.RemoteCast(akVictim, akVictim, akVictim)
	
	if akVictim == game.getplayer()
		SexLab.AdjustPlayerPurity(-5.0)
	endIf
endFunction

Event OnUpdate()

    Cell c = game.getplayer().GetParentCell()
	Actor akactor
	int followerIndex = 0
	Int NumRefs = c.GetNumRefs(43)
	While (NumRefs > 0)
		NumRefs -= 1
		akactor = c.GetNthRef(NumRefs, 43) as Actor
		actor aktarget = akactor.GetCombatTarget()
		If aktarget != none 
			if aktarget.IsInFaction(ECVictimfaction) && akactor.GetDistance(aktarget) < 2500
				if ( !akactor.IsInFaction(ECTentaclefaction) )
					akactor.AddToFaction(ECTentaclefaction)
					Spectator[SpectatorCount] = akactor as Actor
					SpectatorCount +=  1
				endif
				aktarget.stopcombatAlarm()
				akactor.stopcombat()
				if SpectatorControl.isStopped()
					SpectatorControl.start()
				endif
			endif
		Endif
	EndWhile 


EndEvent

function stripFollower(actor akVictim)

	Form ItemRef = None
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(32))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(31))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(30))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(33))
	StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(34))
	StripItem(akVictim, ItemRef)
	;ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(37)) #You can keep your boots on!#
	;StripItem(akVictim, ItemRef)
	ItemRef = akVictim.GetWornForm(Armor.GetMaskForSlot(38))
	StripItem(akVictim, ItemRef)	
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
		if !akArmor.haskeyword(zzEstrusChaurusArmor)
			akVictim.UnequipItem(ItemRef, false, true)
		endif
	endif
endfunction
