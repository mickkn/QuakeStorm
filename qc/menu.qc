float	modelindex_player, modelindex_eyes; //Stores your player model
// Got to float the above early

// MENU.QC
// Here are all the functions and subroutines for the menu system
// Done by Michl
// Modified for CS-Bomb tuts by Koolio, Koolio@mdqnet.net
// Started October 24th, 1999
// Bomb mission started August 17, 2000

void() MainMenu;
void() MenuSelect;
//You have to define these before they are being used. Because MenuToggle calls MainMenu() before it's being written

void() MenuToggle = //This turns the menu on and off
{
	if (self.menu == MENU_OFF) { // if it's off
    	self.menu = MENU_SELECT_TEAM; //Turn it on and go to the proper menu page
        MainMenu ();
    }
	else
		MenuSelect (); //Otherwise it's already on so use it to select stuff from the menu
};

//MainMenu() shows different pages depending on what you selected.
//You should be able to guess what each section does. That's why the MENU_'s etc come in handy.
//If I used a 1,2,3 system instead you'd have a pretty hard time to guess what this means

void() MainMenu =	//Koolio,The menu selection has an exit that is quite useless
			//Later on we'll change that to a random team select
{
	if (self.menu == MENU_SELECT_TEAM) {
	        self.menu = MENU_SELECT_TEAM;
	        centerprint (self, "   >Select team\n        Exit           ");
	        return;
	}
	if (self.menu == MENU_SELECT_EXIT) {
		self.menu = MENU_SELECT_EXIT;
	    centerprint (self, "    Select team\n       >Exit           ");
	    return;
	}
	if (self.menu == ATTACKER_TEAM) {
		centerprint (self, "  Deffender\n>Attacker");
	}
	else if (self.menu == DEFFENDER_TEAM) {
		centerprint (self, " >Deffender\n Attacker");
	}
};

void() MenuSelect = {	// selects the current menu item
	if (self.menu == MENU_SELECT_TEAM) {
        	self.menu = DEFFENDER_TEAM;
            return;
    	}
    if (self.menu == MENU_SELECT_EXIT) {
        	self.menu = MENU_OFF;
            centerprint (self, "");
            return;
        }
	if (self.menu == ATTACKER_TEAM) {
            self.team = self.menu; //Sets your team to the number of the menu, in this case it's 1
        	bprint (PRINT_HIGH, self.netname); //Shows your name to everybody
            bprint (PRINT_HIGH, " is joining the Attacking team\n"); //And a nice little text to show what team you're joining
            self.skin = 0; 			     //Default skin
            //self.weaponmodel = "progs/v_shot.mdl"; //Sets your default weapon model (shotgun)
            self.menu = MENU_OFF;  			//turn the menu off
            centerprint (self, "");               //Remove the menu
            MainMenu ();					
        }
    else if (self.menu == DEFFENDER_TEAM) { 
            self.team = self.menu;
            bprint (PRINT_HIGH, self.netname);
            bprint (PRINT_HIGH, " is joining the Deffending team\n");
            self.skin = 0;
            //self.weaponmodel = "progs/v_shot.mdl";
            self.menu = MENU_OFF;
            centerprint (self, "");
            MainMenu ();
        }
};

void() MenuUp = { // scrolls through the menu
    if (self.menu == MENU_OFF) //If the menu is off
    	return;            //Leave the function
    else if (self.menu == MENU_SELECT_TEAM)
    	self.menu = MENU_SELECT_EXIT;
    else if (self.menu == MENU_SELECT_EXIT)
    	self.menu = MENU_SELECT_TEAM;
    else if (self.menu == DEFFENDER_TEAM)
        self.menu = ATTACKER_TEAM;
    else if (self.menu == ATTACKER_TEAM)
    	self.menu = DEFFENDER_TEAM;
    MainMenu ();
};

void() MenuDown = { //Same as menu up
	if (self.menu == MENU_OFF)
    	return;
    else if (self.menu == MENU_SELECT_TEAM)
        self.menu = MENU_SELECT_EXIT;
	else if (self.menu == MENU_SELECT_EXIT)
		self.menu = MENU_SELECT_TEAM;
	else if (self.menu == DEFFENDER_TEAM)
		self.menu = ATTACKER_TEAM;
	else if (self.menu == ATTACKER_TEAM)
    	self.menu = DEFFENDER_TEAM;
    MainMenu ();
};