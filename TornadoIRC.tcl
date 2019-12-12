############################################################################################# 
##################### TornadoIRC Script for Eggdrop 1.6.xx 
####################### 
# Based on "NickServ Identify Script by DrLinux
# This TCL works with IdleRPG
# Also works with NickServ
# Has a "join channel" and "part channel" command
# Questions? check out irc.damdevil.org -j #damdevil ask for Radien
############################################################################################# 


################################# HOW TO INSTALL ####################################### 
# Just type in the Settings and add Nickserv as a user in the userlist with the right host 
# and give him the flag "I".. and you're done :) 
######################################################################################## 



####### SETTINGS ######## 
#NickServ Info
set bot_nick "TehDragon"
set nickserv_nick "NickServ"
set botnick_pass "Nick_Password"
#IdleRPG Info
set idlerpg_nick "idleRPG"
set idlebot_nick "Pegasus"
set idlenick_pass "IdleRPG_Password"
#URL Links
set idleURL "http://idlerpg.tornadoirc.com/"
set chatURL "http://flash.tornadoirc.com/"
######################### 

### Don't change anything after this unless you know what your doing. you could 
### Break this.... 
############################################################################### 
bind pub o identnick manual_ident
bind pub o identidle manual_idle
bind pub o logout-now manual_logout
bind pub o join pub_addchan
bind pub o part pub_delchan
bind pub - !chatURL pub_flash
bind pub - !idleURL pub_idlerpg
bind dcc o identify manual_identify

proc pub_idlerpg {nick host handle channel testes} {
 set where [lrange $testes 0 end]
 if {$where == ""} {
 putlog "I told \002\[$nick\]\002 about the idleRPG url"
}
 putserv "PRIVMSG $channel :\002\[\002IdleRPG Url\002]\002: $idleURL"
 return 1

}

proc pub_flash {nick host handle channel testes} {
 set where [lrange $testes 0 end]
 if {$where == ""} {
 putlog "I told \002\[$nick\]\002 about the flash url"
}
 putserv "PRIVMSG $channel :\002\[\002Flash Url\002]\002: $chatURL"
 return 1

}
proc pub_addchan {nick host handle channel testes} {
 set where [lrange $testes 0 end]
 if {$where == ""} {
 putserv "NOTICE $nick :Usage is join-now #channel"
}
 channel add $where
 putserv "NOTICE $nick :I have joined $where for you"
 putlog "$nick made me join $where"
 return 1
}
proc pub_delchan {nick host handle channel testes} {
 set where [lrange $testes 0 end]
 if {$where == ""} {
 putserv "NOTICE $nick :Usage is part-now #channel"
}
 channel remove $where
 putserv "notice $nick :I'm no longer in $where"
 putlog "$nick made me leave $where"
 return 1
}
proc manual_ident { nick host handle channel testes } {
 global nickserv_nick botnick_pass bot_nick
 putserv "PRIVMSG $nickserv_nick :identify $botnick_pass"
 putlog "Identifying manualy for nick \002\[$bot_nick\]\002"
}
proc manual_idle { nick host handle channel testes } {
 global idlerpg_nick idlenick_pass idlebot_nick
 putserv "PRIVMSG $idlerpg_nick :login $idlebot_nick $idlenick_pass"
 putlog "Manualy loged into \002\[$idlerpg_nick\]\002 For nick \002\[$idlebot_nick\]\002"
}

proc manual_logout { nick host handle channel testes } {
 global nickserv_nick botnick_pass bot_nick
 putserv "PRIVMSG $nickserv_nick :logout"
 putlog "Logging out for nick \002\[$bot_nick\]\002"
}
proc manual_identify { hand idx mascara } { 
 global nickserv_nick botnick_pass bot_nick 
 putserv "PRIVMSG $nickserv_nick :identify $botnick_pass"    
 putlog "Identifying manualy for nick \002\[$bot_nick\]\002" 
}
####################################################################################### 
#Lets Give DrLinux some credit for what he's done...
putlog "NickServ Identify Script by DrLinux - Loaded."
#Alright, now lets give me some credit..
putlog "Join/Part/IdleRPG Script by Radien - Loaded."
