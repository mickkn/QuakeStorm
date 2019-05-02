/*
===============================================================================

Storm Weapon Functions

===============================================================================
*/




/*
========================================

Railgun

* Auto recharge 1 slug
* Railshot (instant kill)

========================================
*/
void() T_StormRailgunTouch=
{

};

void() StormRailgunThink=
{

};


void(float damage, vector dir) TraceAttack;
void() ClearMultiDamage;
void() ApplyMultiDamage;
void() Multi_Finish;

void(float shotcount, vector dir, vector spread) FireSlugs =
{
	
	local   vector direction;
	direction = dir;
/*
    local vector src;

    makevectors (self.v_angle);
    src = self.origin + v_forward * 10;
    src_z = self.absmin_z + self.size_z * 0.7;
    ClearMultiDamage ();

    traceline (src, src + direction * 4096, FALSE, self);
    if (trace_fraction != 1)
	TraceAttack (50, direction);

    ApplyMultiDamage ();
	Multi_Finish ();
	
	*/
	local   vector  src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	traceline (src, src + dir*2048, FALSE, self);

	while (shotcount > 0)
	{
		direction = dir;
		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (50, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
	Multi_Finish ();
	
};

void() W_StormFireSlugs =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/railgun.wav", 1, ATTN_NORM);
	
	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	
	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	dir = aim (self, 100000);
	FireSlugs (1, dir, '0 0 0');
};

/*
========================================

Rocket Launcher

* Auto recharge 3 rockets
* Semi auto rocket launching
* On touch count as damage
* Rocket jump on self
* No impact on enemy touch

========================================
*/

void(entity targ, entity inflictor, float damage) T_StormDamage =
{
	local   vector  dir;

	// figure momentum add
	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		// Set kickback for smaller weapons

		targ.velocity = targ.velocity + dir * damage * 8;

	}

};

void(entity inflictor, entity attacker, float damage, entity ignore, string dtype) T_StormRadiusDamage =
{
	local   float   points;
	local   entity  head;
	local   vector  org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				
				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{
						head.deathtype = dtype;
						T_StormDamage (head, inflictor, points);
					}
				}
			}
		}
		head = head.chain;
	}
};

void() T_StormRocketTouch =
{
	local float     damg;

	if (other == self.owner) {
		return;         	// don't explode on owner
	}

	if (self.voided) {
		return;
	}
	
	self.voided = 1;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100;
	
	if (other.health)
	{
		other.deathtype = "rocket";
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact


	T_StormRadiusDamage (self, self.owner, 120, other, "rocket");

//  sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8 * normalize(self.velocity);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove(self);
};

void() W_StormFireRocket =
{
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1; 	// Decreasae ammo when fired
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);	// Play sound

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	newmis = spawn ();						// Spawn a rocket
	newmis.owner = self;					// Set owner to self
	newmis.movetype = MOVETYPE_FLYMISSILE;	// Set move type
	newmis.solid = SOLID_BBOX;				// Set the missile model solid
		
	// Set missile speed     
	makevectors (self.v_angle);				
	newmis.velocity = aim(self, 600);		
	newmis.velocity = newmis.velocity * 600;
	newmis.angles = vectoangles(newmis.velocity);
	
	newmis.touch = T_StormRocketTouch;
	newmis.voided = 0;
	
	// Set missile duration (timeout)
	newmis.nextthink = time + 6;
	newmis.think = SUB_Remove;
	newmis.classname = "rocket";

	setmodel (newmis, "progs/missile.mdl");						//
	setsize (newmis, '0 0 0', '0 0 0');             			// 
	setorigin (newmis, self.origin + v_forward*8 + '0 0 16'); 	// Where will the rocket be shoot from
};









/*
========================================================
 OLD STUFF
========================================================
*/

void() T_LaserBolt_Touch =
{
	local float     damg;

	if (other == self.owner)
		return;         // don't explode on owner

	if (self.voided) {
		return;
	}
	
	self.voided = 1;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100;
	
	if (other.health)
	{
		other.deathtype = "rocket";
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact

//  sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8 * normalize(self.velocity);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_SPIKE);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove(self);
};
/*
================
W_FireLaser
================
*/

void() W_FireLaser =
{
	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	
	sound (self, CHAN_WEAPON, "weapons/railgun.wav", 1, ATTN_NORM);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX; // BBOX??
		
// set newmis speed     

	makevectors (self.v_angle);
	newmis.velocity = aim(self, 100000);
	newmis.velocity = newmis.velocity * 100000;
	newmis.angles = vectoangles(newmis.velocity);
	
	newmis.touch = T_LaserBolt_Touch;
	newmis.voided = 0;
	
// set newmis duration
	newmis.nextthink = time + 3;
	newmis.think = SUB_Remove;
	newmis.classname = "rocket";

	setmodel (newmis, "progs/e_spike2.mdl");
	setsize (newmis, '0 0 0', '0 0 0');             
	setorigin (newmis, self.origin + v_forward*8 + '0 0 16');
};


// void () LaserBolt_Touch;
// void () LaserBolt_Think = {
//     self.solid = SOLID_TRIGGER;
//     self.movetype = MOVETYPE_FLYMISSILE;
//     self.velocity = self.oldorigin;
//     self.touch = LaserBolt_Touch;
//     setmodel(self, "progs/e_spike2.mdl");
//     self.nextthink = time + 1;
//     self.think = SUB_Remove;
// };
// 
// /*
// ================
//  Laserbolt touch function. Just moves through the player and comes out
//  the other side.
// ================
// */
// 
// void () LaserBolt_Touch = {
//     local vector org;
// 
//     if (other == self.owner) {
//         return;
//     }
//     if ((other == self.enemy) && (self.enemy != world)) {
//         return;
//     }
// //    if (pointcontents(self.origin) == CONTENT_SKY) {
// //        dremove(self);
// //        return;
// //    }
//     org = self.origin - 8 * normalize(self.velocity);
//     if (other.health) {
//         SpawnBlood(org, 15);
//         //other.deathtype = "rail"; //??
// 		T_Damage (other, self, self.owner, 100 );
//         self.velocity = self.oldorigin;
//         self.owner = other;
//         setmodel(self, string_null);
//         self.touch = SUB_Null;
//         self.nextthink = time + 0.1;
//         self.think = LaserBolt_Think;
//         return;
//     } else {
//         WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
//         WriteByte(MSG_MULTICAST, TE_SPIKE);
//         WriteCoord(MSG_MULTICAST, self.origin_x);
//         WriteCoord(MSG_MULTICAST, self.origin_y);
//         WriteCoord(MSG_MULTICAST, self.origin_z);
//         multicast(self.origin, MULTICAST_PHS);
//     }
//     remove(self);
// };
// 
// void () W_FireLaser = {
//     local vector vec, org;
// 
// 	sound (self, CHAN_WEAPON, "weapons/railgun.wav", 1, ATTN_NORM);
// 
// 	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
// 	
//     makevectors(self.v_angle);
//     org = self.origin + v_forward * 8;
//     vec = aim(self, 1000000);
//     //vec = normalize(vec);
// 
//     newmis = spawn();
//     newmis.owner = self;
//     newmis.enemy = self;
//     newmis.movetype = MOVETYPE_FLYMISSILE;
//     newmis.solid = SOLID_TRIGGER;
// 
//     setmodel(newmis, "progs/e_spike1.mdl");
//     setsize(newmis, '0 0 0', '0 0 0');
// 
//     setorigin(newmis, org + '0 0 16');
// 
//     newmis.velocity = vec * 1000000;
//     newmis.angles = vectoangles(newmis.velocity);
//     newmis.oldorigin = newmis.velocity;
// 
//     newmis.nextthink = time + 10;
//     newmis.think = SUB_Remove;
//     newmis.touch = LaserBolt_Touch;
// };