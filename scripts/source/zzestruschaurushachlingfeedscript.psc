;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname zzEstrusChaurusHachlingFeedScript Extends Package Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(Actor akActor)
;BEGIN CODE
float fHealth = akActor.GetBaseActorValue("health")
float fHeight = akActor.GetActorBase().GetHeight()
float fScale = akActor.GetScale() / fHeight


akActor.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
int i = 0
while i < 100
	fHealth += 0.1
	fScale += 0.01

	akActor.SetScale( fScale )
	akActor.SetActorValue("health", fHealth )
	akActor.QueueNiNodeUpdate()

	Utility.Wait(0.1)
	i += 1
endWhile
akActor.SetAnimationVariableBool("bHumanoidFootIKEnable", true)


akActor.EvaluatePackage()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
