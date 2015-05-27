// STORM objective spawn timer

void() ObjectTimer =
{
	local float timelimit;
	local string a;

	timelimit = cvar("object_timer"); // time limit in sec? not tested
	if (!timelimit) return;
	timelimit = timelimit - time;
	a = ftos (timelimit);
	// SPAWN OBJECTIVE FLAG HERE MAKE IT :)
	specialprint (self,"\n\n\n\n\n\n\n\n\n\n\n\nTime Remaining: ",a,"--","","","","");
};

