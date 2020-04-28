class X2Effect_JulianReturnFire extends X2Effect_ReturnFire;

DefaultProperties
{
	EffectName = "ReturnFire"
	DuplicateResponse = eDupe_Ignore
	AbilityToActivate = "OverwatchShot"
	GrantActionPoint = class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint
	MaxPointsPerTurn = 0
	bDirectAttackOnly = true
	bPreEmptiveFire = false
	bOnlyDuringEnemyTurn = true
}