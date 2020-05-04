class X2Effect_JulianReturnFire extends X2Effect_ReturnFire;

DefaultProperties
{
	EffectName = "JulianReturnFire"
	DuplicateResponse = eDupe_Refresh
	AbilityToActivate = "OverwatchShot"
	GrantActionPoint = class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint
	MaxPointsPerTurn = -1
	bDirectAttackOnly = true
	bPreEmptiveFire = false
	bOnlyDuringEnemyTurn = true
}