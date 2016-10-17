Scriptname zzEstrusChaurusAE extends Quest

; VERSION 1
sslSystemConfig           property SexLabMCM                        auto
SexLabFramework           property SexLab                           auto
Faction                   property chaurus                          auto
Faction                   property SexLabAnimating                  auto
Spell                     property crChaurusParasite                auto 
MagicEffect[]             property crChaurusPoison                  auto 
Armor                     property zzEstrusChaurusParasite          auto  
Armor                     property zzEstrusChaurusFluid             auto  
GlobalVariable            property zzEstrusChaurusFluids            auto  

; VERSION 2
Spell                     property zzEstrusChaurusBreederAbility    auto
Faction                   property zzEstrusChaurusBreederFaction    auto

; VERSION 3
Faction                   property CurrentFollowerFaction           auto
Keyword                   property ActorTypeNPC                     auto

; VERSION 5
zzEstrusChaurusMCMScript  property mcm                              auto 

; VERSION 6
Faction                   property CurrentHireling                  auto

; VERSION 8
Armor                     property zzEstrusChaurusDwemerBinders     auto


; VERSION 11
Faction                   property zzEstrusChaurusExclusionFaction  auto


;Version 12 AE Removal
Actor[] 				  Property myActorsList  					Auto

;Version 13

;zadlibs dDlibs = None
;bool dDLoaded = false

sound 					 Property zzEstrusTentacleFX				Auto

; VERSION 14 - EC+ 3.382
;Actor[]            sexActors *Deprecated*
;sslBaseAnimation[] animations *Deprecated*
;int FxID0 = 0 *Deprecated*
;int FXID1 = 0 *Deprecated*
; VERSION 15 - EC+ 3.383
zzestruschaurusevents  property ECevents                            Auto 

; START AE VERSIONING =========================================================
; This functions exactly as and has the same purpose as the SkyUI function
; GetVersion(). It returns the static version of the AE script.
int function aeGetVersion()
	return 11
endFunction

function aeUpdate( int aiVersion )
	
	int myVersion = 11 

	if (myVersion >= 2 && aiVersion < 2)
		zzEstrusChaurusBreederAbility = Game.GetFormFromFile(0x00019121, "EstrusChaurus.esp") as Spell
		zzEstrusChaurusBreederFaction = Game.GetFormFromFile(0x000160a9, "EstrusChaurus.esp") as Faction
	endIf
	if (myVersion >= 3 && aiVersion < 3)
		myActorsList = New Actor[10]
		myActorsList[0] = Game.GetPlayer()

		CurrentFollowerFaction = Game.GetFormFromFile(0x0005c84e, "Skyrim.esm") as Faction
		ActorTypeNPC = Game.GetFormFromFile(0x00013794, "Skyrim.esm") as Keyword
	endIf
	if (myVersion >= 4 && aiVersion < 4)
		myActorsList = New Actor[20]
		myActorsList[0] = Game.GetPlayer()
	endIf
	if (myVersion >= 5 && aiVersion < 5)	
		mcm = ( self as quest ) as zzEstrusChaurusMCMScript
	endIf
	if (myVersion >= 6 && aiVersion < 6)
		CurrentHireling = Game.GetFormFromFile(0x000bd738, "Skyrim.esm") as Faction
	endIf
	if (myVersion >= 7 && aiVersion < 7)
		myActorsList = New Actor[20]

		int idx = myActorsList.length
		while idx > 1
			idx -= 1
			myActorsList[idx] = none
		endWhile

		myActorsList[0] = Game.GetPlayer()
	endIf
	if (myVersion >= 10 && aiVersion < 10)
		zzEstrusChaurusDwemerBinders = Game.GetFormFromFile(0x00039e74, "EstrusChaurus.esp") as Armor
	endIf
	if (myVersion >= 11 && aiVersion < 11)
		zzEstrusChaurusExclusionFaction = Game.GetFormFromFile(0x0004058b, "EstrusChaurus.esp") as Faction
	endIf

endFunction

function RegisterForSLChaurus()
	
	debug.notification("EC+ "+ mcm.GetStringVer() + " Registered...")
	RegisterForModEvent("OrgasmStart", "onOrgasm")

endfunction

; START EC FUNCTIONS ==========================================================
int function AddCompanions()
	myActorsList[0] = Game.GetPlayer()

	Actor thisActor = none
	Int   thisCount = 0
	Cell  thisCell  = myActorsList[0].GetParentCell()
	Int   idxNPC    = thisCell.GetNumRefs(43)
	
	Bool  check1    = false
	Bool  check2    = false
	Bool  check3    = false
	
	Debug.TraceConditional("$EC_COMPANIONS_CHECK", true)
	
	while idxNPC > 0 && thisCount < 19
		idxNPC -= 1
		thisActor = thisCell.GetNthRef(idxNPC,43) as Actor
		
		check1 = thisActor && !thisActor.IsDead() && !thisActor.IsDisabled()
		check2 = check1 && myActorsList.Find(thisActor) < 0 && thisActor.HasKeyword(ActorTypeNPC)
		check3 = check2 && ( thisActor.GetFactionRank(CurrentHireling) >= 0 || thisActor.GetFactionRank(CurrentFollowerFaction) >= 0 || thisActor.IsPlayerTeammate() )

		if check3
			thisCount += 1
			myActorsList[thisCount] = thisActor
			Debug.TraceConditional("EC::AddCompanions: " + thisActor.GetLeveledActorBase().GetName() + "@"+thisCount, true) ;ae.VERBOSE)
		else
			Debug.TraceConditional("EC::AddCompanions: " + thisActor.GetLeveledActorBase().GetName() + ":false", true) ;ae.VERBOSE)
		endif
	endWhile
	
	return thisCount
endFunction

function RemoveCompanions()
	Int idxNPC = myActorsList.length
	while idxNPC > 1
		idxNPC -= 1
		myActorsList[idxNPC] = none
	endWhile
endFunction


; // Our callback we registered onto the global event 
event onOrgasm(string eventName, string argString, float argNum, form sender)
    ; // Use the HookController() function to get the actorlist
    actor[] actorList = SexLab.HookActors(argString)
    ; // See if a Chaurus was involved
   	if actorlist.length > 1 && actorlist[1].IsInFaction(chaurus)
   		ChaurusImpregnate(actorlist[0], actorlist[1])
   	endif

endEvent


function ChaurusImpregnate(actor akVictim, actor akAgressor)

	bool bGenderOk = mcm.zzEstrusChaurusGender.GetValueInt() == 2 || akvictim.GetLeveledActorBase().GetSex() == mcm.zzEstrusChaurusGender.GetValueInt()

	if !bGenderOk
		return
	endif

	if ( !akVictim.IsInFaction(zzEstrusChaurusBreederFaction) )
		akVictim.AddToFaction(zzEstrusChaurusBreederFaction)
	endIf
	if ( !akVictim.HasSpell(zzEstrusChaurusBreederAbility ) );
		akVictim.AddSpell(zzEstrusChaurusBreederAbility , false)
	endIf
	if ( !akAgressor.IsInFaction(zzEstrusChaurusBreederFaction) )
		akAgressor.AddToFaction(zzEstrusChaurusBreederFaction)
	endIf	
	crChaurusParasite.RemoteCast(akVictim, akVictim, akVictim)
	SexLab.ApplyCum(akvictim, 7)
	
	if akVictim == myActorsList[0]
		SexLab.AdjustPlayerPurity(-5.0)
	endIf

	utility.wait(5) ; Allow time for EC to register oviposition
	akVictim.DispelSpell(crChaurusParasite)

endfunction

function ChaurusSpitAttack(Actor akVictim, Actor akAgressor)

	if mcm.TentacleSpitEnabled
		if utility.randomint(1,100) <= mcm.TentacleSpitChance
			
			if ECEvents.OnECStartAnimation(self, akVictim, 0, true, 0, true)
				if !akAgressor.IsInFaction(zzEstrusChaurusBreederFaction) 
					ECEvents.OnECStartAnimation(self, akVictim, 0, true, 0, true)
					akAgressor.AddToFaction(zzEstrusChaurusBreederFaction)
				endif
			endIf
		endIf
	endif
	
endfunction
