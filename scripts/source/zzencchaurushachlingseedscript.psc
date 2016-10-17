;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname zzEncChaurusHachlingSeedScript Extends Package Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(Actor akActor)
;BEGIN CODE
akActor.setav("Aggression", 2)
akActor.SetAV("Confidence", 4)
akActor.AddToFaction( PredatorFaction )
akActor.SetAlert()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4(Actor akActor)
;BEGIN CODE
akActor.SetAV("Aggression", 0)
akActor.SetAV("Confidence", 0)
akActor.RemoveFromFaction( PredatorFaction )
akActor.SetAlert( false )
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(Actor akActor)
;BEGIN CODE
akActor.SetAV("Aggression", 0)
akActor.SetAV("Confidence", 0)
akActor.RemoveFromFaction( PredatorFaction )
akActor.SetAlert( false )
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Faction Property PredatorFaction  Auto  
