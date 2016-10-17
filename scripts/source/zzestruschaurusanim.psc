Scriptname zzEstrusChaurusAnim extends sslAnimationFactory
SexlabFramework Property Sexlab Auto
zzEstrusChaurusAE Property me Auto

function LoadAnimations()
	Debug.Notification("$EC_ANIM_CHECK");
	SexLab = SexLabUtil.GetAPI()
	If SexLab == None
		Debug.MessageBox("Estrus Chaurus Animation registration failed: Sexlab is none.")
	EndIf
	Slots  = sexlab.AnimSlots
	RegisterAnimation("EstrusTentacleDouble")
	RegisterAnimation("EstrusTentacleSide")
	RegisterAnimation("DwemerMachine")
	RegisterAnimation("DwemerMachine02")
	RegisterAnimation("SlimeCreature")
	RegisterAnimation("OozeCreature")
endFunction


function EstrusTentacleDouble(int id)
	sslBaseAnimation Base = Create(id)
	Base.SetContent(Sexual)
	Base.Name = "Tentacle Double"
	Base.SoundFX = Squishing

	int a1 = Base.AddPosition(Female, addCum=VaginalAnal)
	Base.AddPositionStage(a1, "zzEstrusTentacle01S1", 0)
	;Base.AddPositionStage(a1, "zzEstrusTentacle01S2", 0)
	;Base.AddPositionStage(a1, "zzEstrusTentacle01S3", 0)
	;Base.AddPositionStage(a1, "zzEstrusTentacle01S4", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle01S41", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle01S42", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle01S43", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle01S5", 0)
	;Base.AddPositionStage(a1, "zzEstrusTentacle01S6", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle01S61", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle01S62", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle01S63", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon01Up", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon02Up", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon03Up", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon04Up", 0)
	Base.AddPositionStage(a1, "zzEstrusGetUpFaceUp", 0)

	Base.AddTag("Estrus")
	Base.AddTag("Tentacle")
	Base.AddTag("PCKnownAnim")

	Base.Save(id)
endFunction


function EstrusTentacleSide(int id)
	sslBaseAnimation Base = Create(id)
	Base.name = "Tentacle Side"
	Base.SetContent(Sexual)
	Base.SoundFX = Squishing

	int a1 = Base.AddPosition(Female, addCum=VaginalAnal)
	Base.AddPositionStage(a1, "zzEstrusTentacle02S1", 0)
	;Base.AddPositionStage(a1, "zzEstrusTentacle02S2", 0)
	;Base.AddPositionStage(a1, "zzEstrusTentacle02S3", 0)
	;Base.AddPositionStage(a1, "zzEstrusTentacle02S4", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle02S41", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle02S42", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle02S43", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle02S5", 0)
	;Base.AddPositionStage(a1, "zzEstrusTentacle02S6", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle02S61", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle02S62", 0)
	Base.AddPositionStage(a1, "zzEstrusTentacle02S63", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon01Down", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon02Down", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon03Down", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon04Down", 0)
	Base.AddPositionStage(a1, "zzEstrusGetUpFaceDown", 0)

	Base.AddTag("Estrus")
	Base.AddTag("Tentacle")
	Base.AddTag("PCKnownAnim")

	Base.Save(id)
endFunction

function DwemerMachine(int id)
	sslBaseAnimation Base = Create(id)
	Base.name = "Dwemer Machine"
	Base.SetContent(Sexual)
	Base.SoundFX = Squishing

	int a1 = Base.AddPosition(Female, addCum=Vaginal)
	Base.AddPositionStage(a1, "zzEstrusMachine01S1", 0)
	;Base.AddPositionStage(a1, "zzEstrusMachine01S2", 0)
	;Base.AddPositionStage(a1, "zzEstrusMachine01S3", 0)
	;Base.AddPositionStage(a1, "zzEstrusMachine01S4", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine01S41", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine01S42", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine01S43", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine01S5", 0)
	;Base.AddPositionStage(a1, "zzEstrusMachine01S6", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine01S61", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine01S62", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine01S63", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon01Up", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon02Up", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon03Up", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon04Up", 0)
	Base.AddPositionStage(a1, "zzEstrusGetUpFaceUp", 0)

	Base.AddTag("Estrus")
	Base.AddTag("Dwemer")
	Base.AddTag("Machine")
	Base.AddTag("PCKnownAnim")

	Base.Save(id)

endFunction

function DwemerMachine02(int id)
	sslBaseAnimation Base = Create(id)
	Base.name = "Dwemer Machine 2"
	Base.SetContent(Sexual)
	Base.SoundFX = Squishing

	int a1 = Base.AddPosition(Female, addCum=Vaginal)
	Base.AddPositionStage(a1, "zzEstrusMachine02S1", 0)
	;Base.AddPositionStage(a1, "zzEstrusMachine02S2", 0)
	;Base.AddPositionStage(a1, "zzEstrusMachine02S3", 0)
	;Base.AddPositionStage(a1, "zzEstrusMachine01S4", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine02S41", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine02S42", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine02S43", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine02S5", 0)
	;Base.AddPositionStage(a1, "zzEstrusMachine01S6", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine02S61", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine02S62", 0)
	Base.AddPositionStage(a1, "zzEstrusMachine02S63", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon01Down", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon02Down", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon03Up", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon04Up", 0)
	Base.AddPositionStage(a1, "zzEstrusGetUpFaceDown", 0)

	Base.AddTag("Estrus")
	Base.AddTag("Dwemer")
	Base.AddTag("Machine")
	Base.AddTag("PCKnownAnim")

	Base.Save(id)

endFunction


function SlimeCreature(int id)
	sslBaseAnimation Base = Create(id)
	Base.name = "Slime Creature"

	Base.SetContent(Sexual)
	Base.SoundFX = Squishing

	int a1 = Base.AddPosition(Female, addCum=Vaginal)
	;Base.AddPositionStage(a1, "zzEstrusFleeIdle01", 0)
	;Base.AddPositionStage(a1, "zzEstrusFleeIdle02", 0)
	Base.AddPositionStage(a1, "zzEstrusETC02S1", 0)
	;Base.AddPositionStage(a1, "zzEstrusETC02S2", 0)
	;Base.AddPositionStage(a1, "zzEstrusETC02S3", 0)
	Base.AddPositionStage(a1, "zzEstrusETC02S41", 0)
	Base.AddPositionStage(a1, "zzEstrusETC02S42", 0)
	Base.AddPositionStage(a1, "zzEstrusETC02S43", 0)
	Base.AddPositionStage(a1, "zzEstrusETC02S5", 0)
	Base.AddPositionStage(a1, "zzEstrusETC02S61", 0)
	Base.AddPositionStage(a1, "zzEstrusETC02S62", 0)
	Base.AddPositionStage(a1, "zzEstrusETC02S63", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon01Up", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon02Up", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon03Up", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon04Up", 0)
	Base.AddPositionStage(a1, "zzEstrusGetUpFaceUp", 0)

	Base.AddTag("Estrus")
	Base.AddTag("Slime")
	Base.AddTag("PCKnownAnim")

	Base.Save(id)

endFunction

function OozeCreature(int id)
	sslBaseAnimation Base = Create(id)
	Base.name = "Ooze Creature"

	Base.SetContent(Sexual)
	Base.SoundFX = Squishing

	int a1 = Base.AddPosition(Female, addCum=Vaginal)
	;Base.AddPositionStage(a1, "zzEstrusFleeIdle01", 0)
	;Base.AddPositionStage(a1, "zzEstrusFleeIdle02", 0)
	Base.AddPositionStage(a1, "zzEstrusETC07S1", 0)
	;Base.AddPositionStage(a1, "zzEstrusETC02S2", 0)
	;Base.AddPositionStage(a1, "zzEstrusETC02S3", 0)
	Base.AddPositionStage(a1, "zzEstrusETC07S41", 0)
	Base.AddPositionStage(a1, "zzEstrusETC07S42", 0)
	Base.AddPositionStage(a1, "zzEstrusETC072S43", 0)
	Base.AddPositionStage(a1, "zzEstrusETC07S5", 0)
	Base.AddPositionStage(a1, "zzEstrusETC07S61", 0)
	Base.AddPositionStage(a1, "zzEstrusETC07S62", 0)
	Base.AddPositionStage(a1, "zzEstrusETC07S63", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon01Up", 0)
	Base.AddPositionStage(a1, "zzEstrusCommon02Up", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon03Up", 0)
	;Base.AddPositionStage(a1, "zzEstrusCommon04Up", 0)
	Base.AddPositionStage(a1, "zzEstrusGetUpFaceUp", 0)

	Base.AddTag("Estrus")
	Base.AddTag("Ooze")
	Base.AddTag("PCKnownAnim")

	Base.Save(id)

endFunction