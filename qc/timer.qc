// STORM objective spawn timer

void() ObjectTimer =
{
	local float storm_timelimit;
	local string a;

	storm_timelimit = cvar("object_timer"); // time limit in sec? not tested
	if (!timelimit) return;
	storm_timelimit = storm_timelimit - time;
	a = ftos (timelimit);
	// SPAWN OBJECTIVE FLAG HERE MAKE IT :)
	specialprint (self,"\n\n\n\n\n\n\n\n\n\n\n\nTime Remaining: ",a,"--","","","","");
};
