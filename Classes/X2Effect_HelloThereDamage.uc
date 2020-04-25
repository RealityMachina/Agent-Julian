class X2Effect_HelloThereDamage extends X2Effect_ApplyDirectionalWorldDamage;
// main purpose here is to add in targetconditions check BEFORE we apply world damage
// otherwise we make everything act like XCOM 2 again

simulated function ApplyEffectToWorld(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local XComGameStateContext_Ability AbilityContext;
    local XComGameState_Ability AbilityStateObject;
	local XComGameState_Unit SourceUnit, TargetUnit;
	local int i;
	local X2Condition kCondition;
	local name AvailableCode;
    
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	if( AbilityContext != none )
	{
        AbilityStateObject = XComGameState_Ability(`XCOMHistory.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
		SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

        // our addition here: stop if we don't fit any of the requirements to apply world damage
        foreach TargetConditions(kCondition)
        {		
            AvailableCode = kCondition.AbilityMeetsCondition(AbilityStateObject, TargetUnit);
            if (AvailableCode != 'AA_Success')
                return;

            AvailableCode = kCondition.MeetsCondition(TargetUnit);
            if (AvailableCode != 'AA_Success')
                return;
            
            AvailableCode = kCondition.MeetsConditionWithSource(TargetUnit, SourceUnit);
            if (AvailableCode != 'AA_Success')
                return;		
        }
		ApplyDirectionalDamageToTarget(SourceUnit, TargetUnit, NewGameState);

		for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; ++i)
		{
			TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[i].ObjectID));
			ApplyDirectionalDamageToTarget(SourceUnit, TargetUnit, NewGameState);
		}
	}
}