class_name CardDefinition

enum Type{
	Magic, 
	Minion,
	None
}

enum Belong{
	Shoping_Shop, 
	Shopping_Desk,
	Shopping_Hand,
	Shopping_Free,
	Enemy_Desk, 
	Enemy_Hand, 
	Player_Desk, 
	Player_Hand, 
	Player_Free, 
	Enemy_Free,
	None,
}

enum MoveState{
	Move,
	Stop
}

enum Behavior{
	Follow,
	Drag,
	None
}
