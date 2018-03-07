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
;Actor[] 				  Property myActorsList  					Auto    Deprecated in Version 16

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

; VERSION 16 - EC+ 4.11

; VERSION 17 - EC+ 4.30

Race Property ChaurusRace Auto ;Deprecated
Race Property ChaurusReaperRace Auto ;Deprecated
Formlist Property zzEstrusChaurusRaceList Auto

zzestruschaurusevents  property ECevents                            Auto 

; START AE VERSIONING =========================================================
; This functions exactly as and has the same purpose as the SkyUI function
; GetVersion(). It returns the static version of the AE script.
int function aeGetVersion()
	return 11
endFunction

function aeUpdate( int aiVersion )
	
	int myVersion = 17

	if (myVersion >= 2 && aiVersion < 2)
		zzEstrusChaurusBreederAbility = Game.GetFormFromFile(0x00019121, "EstrusChaurus.esp") as Spell
		zzEstrusChaurusBreederFaction = Game.GetFormFromFile(0x000160a9, "EstrusChaurus.esp") as Faction
	endIf
	if (myVersion >= 3 && aiVersion < 3)
		;myActorsList = New Actor[10] 			Deprecated
		;myActorsList[0] = Game.GetPlayer()		Deprecated

		CurrentFollowerFaction = Game.GetFormFromFile(0x0005c84e, "Skyrim.esm") as Faction
		ActorTypeNPC = Game.GetFormFromFile(0x00013794, "Skyrim.esm") as Keyword
	endIf
	if (myVersion >= 4 && aiVersion < 4)
		;myActorsList = New Actor[20]			Deprecated
		;myActorsList[0] = Game.GetPlayer()		Deprecated
	endIf
	if (myVersion >= 5 && aiVersion < 5)	
		mcm = ( self as quest ) as zzEstrusChaurusMCMScript
	endIf
	if (myVersion >= 6 && aiVersion < 6)
		CurrentHireling = Game.GetFormFromFile(0x000bd738, "Skyrim.esm") as Faction
	endIf
	if (myVersion >= 7 && aiVersion < 7)
		;myActorsList = New Actor[20] 			Deprecated

		;int idx = myActorsList.length			Deprecated
		;while idx > 1							Deprecated
		;	idx -= 1							Deprecated
		;	myActorsList[idx] = none			Deprecated
		;endWhile								Deprecated

		;myActorsList[0] = Game.GetPlayer()		Deprecated
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
	InitModEvents()

endfunction

function InitModEvents()
	RegisterForModEvent("OrgasmStart", "onOrgasm")
endfunction

; START EC FUNCTIONS ==========================================================

; // Our callback we registered onto the global event 
event onOrgasm(string eventName, string argString, float argNum, form sender)
   if mcm.zzEstrusDisablePregnancy.GetValueInt()
    	return
    endif
    int tid = argString as Int	
   	; // Use the HookController() function to get the actorlist
    actor[] actorList = SexLab.GetController(tid).Positions; SexLab.HookActors(argString)
    ; // See if a Chaurus was involved  - SD+ Faction changes mean we can't rely on a faction check
   	if actorlist.length > 1 && zzEstrusChaurusRaceList.HasForm(actorlist[1].GetRace()) && Sexlab.PregnancyRisk(tid, actorlist[0], false, true) 
   		ChaurusImpregnate(actorlist[0], actorlist[1])
   	endif

endEvent

function ChaurusImpregnate(actor akVictim, actor akAgressor)

	bool bGenderOk = mcm.zzEstrusChaurusGender.GetValueInt() == 2 || akvictim.GetLeveledActorBase().GetSex() == mcm.zzEstrusChaurusGender.GetValueInt()
	Bool invalidateVictim = !bGenderOk || ( akVictim.IsInFaction(zzEstrusChaurusExclusionFaction) || akVictim.IsBleedingOut() || akVictim.isDead() )
	
	if invalidateVictim
		return
	endif

	ECevents.Oviposition(akvictim)

	if ( !akAgressor.IsInFaction(zzEstrusChaurusBreederFaction) )
		akAgressor.AddToFaction(zzEstrusChaurusBreederFaction)
	endIf	
	
	SexLab.ApplyCum(akvictim, 7)

	utility.wait(5) ; Allow time for EC to register oviposition and crowd control to kick in
	akVictim.DispelSpell(crChaurusParasite)

endfunction

function ChaurusSpitAttack(Actor akVictim, Actor akAgressor)

	if mcm.TentacleSpitEnabled
		if utility.randomint(1,100) <= mcm.TentacleSpitChance
			
			if ECEvents.OnECStartAnimation(self, akVictim, 0, true, 0, true)
				if !akAgressor.IsInFaction(zzEstrusChaurusBreederFaction) 
					akAgressor.AddToFaction(zzEstrusChaurusBreederFaction)
				endif
			endIf
		endIf
	endif
	
endfunction
