class X2Condition_HelloThere extends X2Condition;

function name CheckMeetsCondition( XComGameState_Ability kAbility, XComGameState_Unit TargetUnitState, XComGameState_Unit UnitState )
{
	local XComGameState_Item SourceWeapon, PrimaryWeapon;
    local int ClipSize;
	if( UnitState != None )
	{
		PrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
		SourceWeapon = ( kAbility != None ) ? kAbility.GetSourceWeapon() : PrimaryWeapon;
		if( SourceWeapon != None )
		{
           ClipSize = SourceWeapon.GetClipSize();
			`log(SourceWeapon.GetMyTemplateName() $ " has the following ammo loaded into it " $ ClipSize);
            if(SourceWeapon.Ammo < (ClipSize - 1)) // this means more than two shots were taken:
            {
				`log("It is not enough for Hello There");
                // just for future me
                // clipsize means we're taking our first shot
                // clipsize - 1 means we're taking our second shot
                // this way I don't fuck up the math in later updates
               return 'AA_ClipIsNotFull';
            }
		}
	}
	return 'AA_Success';
}

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit UnitState, TargetUnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	TargetUnitState = XComGameState_Unit(kTarget);
	return CheckMeetsCondition( kAbility, TargetUnitState, UnitState );
}
event name CallMeetsConditionWithSource( XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource )
{
	local XComGameState_Unit UnitState, TargetUnitState;

	UnitState = XComGameState_Unit(kSource);
	TargetUnitState = XComGameState_Unit(kTarget);
	return CheckMeetsCondition( None, TargetUnitState, UnitState );
}