//Observer mode, you start out as this if you don't have a team
//Basically modified PutClientInServer to be more like an observer mode

void() PutObserverInServer = {		//Koolio, Just like PutClientInServer
	if ( self.team != OBSERVER ) {	// if you already have a team  
		PutClientInServer(); 				// And run the normal PutClientInServer
		centerprint (self, "You have a team");
		return; 
	}
	local	entity spot;

	spot = SelectSpawnPoint ();

	self.classname = "observer";
	self.health = 666;									//Heh, just for fun
	self.takedamage = DAMAGE_NO;  		//You can't take damage
	self.solid = SOLID_NOT;      			 		//You're not solid (so you can't (be) telefrag(ged)
	self.movetype = MOVETYPE_NOCLIP;	//You can move just like in noclipping mode
	self.show_hostile = 0;							//The rest is pretty much the same as in PutClientInServer
	self.max_health = 666;
	self.flags = FL_CLIENT;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;

	self.items = 0;
	self.ammo_shells = 0;
	self.ammo_rockets = 0;

	W_SetCurrentAmmo ();

	self.attack_finished = time;	
	self.deadflag = DEAD_NO;
// pausetime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

// oh, this is no longer a hack!  =)
	//setmodel (self, "progs/eyes.mdl");
	//modelindex_eyes = self.modelindex;

	setmodel (self, "progs/eyes.mdl"); //We're going to replace this soon
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

	player_stand1 ();
	
	if (deathmatch) {
		makevectors(self.angles);
		//spawn_tfog (self.origin + v_forward*20); //You can uncomment this if you want the normal fog to apear
									 //Like it does with players
	}

	spawn_tdeath (self.origin, self);
};