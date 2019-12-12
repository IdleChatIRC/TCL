#############################################################################
#                                                                           # 
# Coded by: dragon (dragon@uberdragon.net)                                  #
# Version: 1.4                                                              #
# Released: March 14th, 2009                                                #
#                                                                           #
# Description: Used to automatically log you into the idleRPG game bot      #
#              upon entering the idleRPG game channel.  This script won't   #
#              automatically make you join the channel so set that up in    #
#              in your .conf or with +chan                                  #
#                                                                           #
# Available Commands:                                                       #
# - DCC: .irpg : Attempts to force a login to the idleRPG bot               #
#                                                                           #
# History:                                                                  #
#	  - 1.4: Fixed a issue with the multiple timer respawns             #
#         - 1.3: First public release                                       #
#         - 1.2: Set a timer to check for +v and if missing login to bot    #
#         - 1.1: Added dcc ability .irpg                                    #
#         - 1.0: First concept - login on join.                             #
#                                                                           #
# Report bugs/suggestion to dragon@uberdragon.net                           #
# or visit /server irc.uberdragon.net and join #uberdragon                  #
#                                                                           #
# This program is free software; you can redistribute it and/or modify      #
# it under the terms of the GNU General Public License as published by      #
# the Free Software Foundation; either version 2 of the License, or         #
# (at your option) any later version.                                       #
#                                                                           #
# This program is distributed in the hope that it will be useful,           #
# but WITHOUT ANY WARRANTY; without even the implied warranty of            #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
# GNU General Public License for more details.                              #
#                                                                           #
# You should have received a copy of the GNU General Public License         #
# along with this program; if not, write to the Free Software               #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA #
#                                                                           #
#############################################################################
#############################################################################


# This is the full login string sent via msg to the idle RPG bot
# example: set irpg(login) "login character password"
set irpg(login) "login name pass"

# Nick of idle RPG bot
set irpg(nick) "idleRPG"

# Channel idleRPG is played in
set irpg(chan) "#idleRPG"

# Number of minutes to check +v status 
set irpg(timer) 3

# replace #idleRPG with the actual channel for the game on your network
bind join - #idleRPG* loginIRPG


#############################################################################
# You shouldn't need to edit past here
#############################################################################
bind dcc - irpg checkIRPG

proc loginIRPG {nick uhost hand chan} {
	global irpg botnick
	if {$nick == $botnick} {
		puthelp "PRIVMSG $irpg(nick) :$irpg(login)"
	}
} 

proc checkIRPG {handle idx text} {
	global botnick irpg 
	if {[botonchan $irpg(chan)] && ![isvoice $botnick $irpg(chan)]} { 
		puthelp "PRIVMSG $irpg(nick) :$irpg(login)" 
		putlog "relogging into iRPG"
	} else { 
		putlog "You have voice in $irpg(chan) but ...."
		puthelp "PRIVMSG $irpg(nick) :$irpg(login)"
	}
}

proc timeCheckIRPG {} {
        global botnick irpg
        if {[botonchan $irpg(chan)] && ![isvoice $botnick $irpg(chan)]} {
                puthelp "PRIVMSG $irpg(nick) :$irpg(login)"
                putlog "You seem to be missing voice in $irpg(chan)... relogging into bot"
        }
	set irpg(running) [timer $irpg(timer) timeCheckIRPG]
        return 1
}


if {[info exists irpg(running)]} {killtimer $irpg(running)}
set irpg(running) [timer 3 timeCheckIRPG]


putlog "Script idleRPG v1.4 by dragon of irc.uberdragon.net loaded!  dcc command .irpg available..."
