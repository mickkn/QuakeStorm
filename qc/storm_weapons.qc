/*
===============================================================================

Storm Weapon Functions

===============================================================================
*/

/*
========================================

Railgun

* Auto recharge 1 slug
* Railshot a lot of damage

========================================
*/

void(float damage, vector dir) TraceAttack;
void() ClearMultiDamage;
void() ApplyMultiDamage;
void() Multi_Finish;

// Shotgun modified with some lightning strike :)
void(float shotcount, vector dir, vector spread) FireSlugs =
{
	local vector org;
	local vector src;
	
	local float dmg = 100;
	
	//makevectors(self.v_angle);

	src = self.origin + v_forward*10;	
	src_z = self.size_z;				// Hit on crosshair

	ClearMultiDamage ();

	traceline (src, src + dir*2048, FALSE, self);
	if (trace_fraction != 1.0)
	{
		TraceAttack (dmg, dir);
	}

	puff_org = trace_endpos;	// Make a spark on the wall

	org = self.origin + '0 0 0';
	
	// Draw trace using shaft model
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNING2);
	WriteEntity (MSG_MULTICAST, self);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	WriteCoord (MSG_MULTICAST, trace_endpos_x);
	WriteCoord (MSG_MULTICAST, trace_endpos_y);
	WriteCoord (MSG_MULTICAST, trace_endpos_z);
	multicast (org, MULTICAST_PHS);

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
	local float     dmg;

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

	dmg = 100;
	
	if (other.health)
	{
		other.deathtype = "rocket";
		T_Damage (other, self, self.owner, dmg );
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