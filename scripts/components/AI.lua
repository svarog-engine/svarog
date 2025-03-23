
AIMoveTowardsPlayer = ECS.Component{
	chance = 5
}

AIKeepDistanceFromPlayer = ECS.Component{
	distance = 5, 
	chance = 5
}

AISpawnWhenDistantFromPlayer = ECS.Component{
	min = 4, 
	max = 7,
	chance = 2,
	what = "Rat"
}

AIAttackIfStandingNextTo = ECS.Component{}

AIRest = ECS.Component{ chance = 9 }
AIBreakThroughToPlayer = ECS.Component{ distance = 9 }
AIForcedRandomWalk = ECS.Component{}
AIMoveTowardsPlayerThroughShadows = ECS.Component{ chance = 5 }