# Simple !learn TCL that supports several defenition lines
# Created by Hal9000 @ irc.PTnet.org
#
# !learn add word defenition
# !learn del word <number|all>
# and also !learn <ins|put|rep> <number> <defenition>
#
# You can see a defenition using whatis <word>
# You can search inside the whole file (including defenitions) using ** word
# Large defenitions (more than six lines) will be sent into the user so the
# chan wont be flooded. You can force sending to channel the same way you can
# force sending to nicks.
# whatis defenition > nick
#
# What does this script has different from other so common whatis scripts?
# The characters are treated properly. Chars like ';' or '[' are properly handled
# and there have been no problems untill now.
# Also we have a multi line support... and a "repeat explain" protection.
#
# Inspired on fluxlearn TCL.
#
# Some additional features, sugestions and bufixes from
#   Status@brasnet.org aka Juvenal@PTnet.org
#
# If you find any bug, pleas bug me at hal9000@gupe.net

# PLEASE CHANGE THE LINE BELOW. If you don't, the file and the directory will be
# created
set learn_db "/home/radien/eggdrop/logs/hal-learn.dat"


### - ### No need to edit below this line... ### - ###
# or at least i hope so ;)

putlog "!learn TCL by Hal9000 @ irc.ptnet.org loaded."

bind pub m !learn learn_learn
bind pub - "whatis" learn_explain
bind pub - "\*\*" learn_search

set learn_whodid ""

proc learn_learn { nick uhost hand chan args } {
 set args [lindex $args 0]
 set args [split $args " "]
 switch [lindex $args 0] {
  "add" {
   if {[lindex $args 2] == ""} {
    puthelp "NOTICE $nick :Try !learn add word defenition!" 
   } else {
      learn_addEntry $nick [lindex $args 1] [lrange $args 2 end]
      puthelp "NOTICE $nick :Defenition added"
      learn_flood "[lindex $args 1]" $chan
     }
  }
  "del" {
   if {[lindex $args 2]!=""} {
    learn_delEntry [lindex $args 1] [lindex $args 2]
    puthelp "NOTICE $nick :Defenition removed"
    learn_flood "[lindex $args 1]" $chan
   } else {
      learn_delEntry [lindex $args 1]
      puthelp "NOTICE $nick :Defenition removed"
     }
  }
  "ins" {
   if {[lindex $args 3]!=""} {
    learn_insEntry [lindex $args 1] [lindex $args 2] [lrange $args 3 end]
    puthelp "NOTICE $nick :Defenition inserted"
    learn_flood "[lindex $args 1]" $chan
   } else {puthelp "NOTICE $nick :Syntax: !learn ins word num text" }
  }
  "put" {
   if {[lindex $args 3]!=""} {
    learn_putEntry [lindex $args 1] [lindex $args 2] [lrange $args 3 end] $nick
    puthelp "NOTICE $nick :Defenition inserted"
    learn_flood "[lindex $args 1]" $chan
   } else {puthelp "NOTICE $nick :Syntax: !learn put word num text" }
  }
  "rep" {
   if {[lindex $args 3]!=""} {
    learn_repEntry [lindex $args 1] [lindex $args 2] [lrange $args 3 end]
    puthelp "NOTICE $nick :Defenition replaced"
    learn_flood "[lindex $args 1]" $chan
   } else {puthelp "NOTICE $nick :Syntax: !learn rep word num text" }
  }  
  default { puthelp "NOTICE $nick :Syntax: \002!learn <add|del|info|ins|rep>" }
 }
}

proc learn_explain { nick uhost hand chan args } {
	global learn_db learn_whodid;if {![info exists learn_whodid]} {set learn_whodid ""}
	set real_chan $chan
	set args [split [lindex $args 0] " "]
	if {$args == ""} { puthelp "PRIVMSG $chan :\002whatis\[\002x\002]: Usage: whatis <word> \[> nick]" ; return }
	set explain [string tolower [lindex $args 0]]; set chan [string tolower $chan]
	if {([lindex $args 1] == ">" || [lindex $args 1] == ">>") && [lindex $args 2] != ""} { set chan [lindex $args 2] 
#         if {[lsearch -exact $learn_whodid [list $explain [string tolower $chan]]] != -1} {
#                puthelp "PRIVMSG $real_chan :\002Hey ${nick}, i've already told $chan about \"$explain\"... no need to repeat (i think)"
#                return 0
#         }
	}
	set fp [open $learn_db r];set allEntrys ""
	while {![eof $fp]} {gets $fp curEntry;set curEntry [split $curEntry " "];if {[string equal -nocase [lindex $curEntry 1] $explain]} {lappend allEntrys [join $curEntry " "]}}
	close $fp
	set count 0
	if {[llength $allEntrys]==1} {
	 if {[lsearch -exact $learn_whodid [list $explain [string tolower $chan]]] != -1} {
		puthelp "PRIVMSG $real_chan :\002Hey ${nick}, i've already told $chan about \"$explain\"... no need to repeat (i think)"
		return 0
	 } else { puthelp "PRIVMSG $chan :\002\037${explain}\037: \002[join [lrange [split [lindex $allEntrys 0] " "] 2 end]]";incr count }
	} else {
	 if {[llength $allEntrys]>6&&[string index $chan 0]=="#"&&!(([lindex $args 1] == ">" || [lindex $args 1] == ">>") && [lindex $args 2] != "")} {set chan $nick; 
          puthelp "PRIVMSG $real_chan :\002\037${explain}?\002\037 What a huge defenition... i'll tell you in private instead..."
	 }
         if {[lsearch -exact $learn_whodid [list $explain [string tolower $chan]]] != -1} {
                puthelp "PRIVMSG $real_chan :\002Hey ${nick}, i've already told you about \"$explain\"... no need to repeat (i think)"
                return 0
	 }
	 foreach curEntry $allEntrys {
		incr count
		puthelp "PRIVMSG $chan :\002\037${explain}\[\037\002${count}\002\037]:\037 \002[join [lrange [split $curEntry " "] 2 end]]"
	} }
	if {$count == 0} { puthelp "PRIVMSG $chan :\002${explain}\[\002x\002\]: \002No definition found laaabaseball ate it." }
	if {([lindex $args 1] == ">" || [lindex $args 1] == ">>") && [lindex $args 2] != ""} {
		puthelp "NOTICE $nick :Ok, done."
	}
	lappend learn_whodid [list $explain [string tolower $chan]]
	set explain [learn_filterstr $explain]	;# Don't allow code to be executed
	set chan [learn_filterstr $chan]	;# ensure []s are properly handled...
	utimer 60 "learn_flood \"$explain\" \"$chan\""
}

proc learn_flood {word target} {
	# removes from "already told so" list
	global learn_whodid
	set word [string tolower $word]; set target [string tolower $target]
	set lin [lsearch -exact $learn_whodid [list $word $target]] 
	if {$lin == -1} {
		return
	} else {
		set learn_whodid [lreplace $learn_whodid $lin $lin]
	}
}

proc learn_addEntry { nick word defenition } {
 global learn_db;set word [string tolower $word]
 if {![file exists $learn_db]} {file mkdir [lindex [split $learn_db /] 0];set fp [open $learn_db w+]
  puts $fp "Hal9000 ?? Just do a \002?? \037word\037\002 or \002?? \037word\037 > \037nick\037\002"
  puts $fp "Hal9000 !learn hal-learn script | mantained by the #Eggdrop team at irc.PTnet.org"
 } else {set fp [open $learn_db a]};puts $fp "$nick $word [join $defenition]";close $fp
}

proc learn_delEntry { word {remnum "all"}} {
 global learn_db
 set word [string tolower $word]
 set fp [open $learn_db r]
 set allEntrys ""
 set count 1
 if {$remnum == "all"} {
  while {![eof $fp]} {gets $fp curEntry;if {![string equal -nocase [lindex [split $curEntry] 1] $word]} {lappend allEntrys $curEntry}}
 } else {
  while {![eof $fp]} {
   gets $fp curEntry
   if {![string equal -nocase [lindex [split $curEntry] 1] $word] || ($count != $remnum && $remnum != -2)} {
    if {[info exists curEntry]&&$curEntry!=""} {lappend allEntrys $curEntry}
    if {[string equal -nocase [lindex [split $curEntry] 1] $word]} {incr count}
   } else {incr count}
  }
 }
 close $fp;set fp [open $learn_db w];foreach curEntry $allEntrys {puts $fp $curEntry};close $fp
}

proc learn_insEntry {word num text} {
 global learn_db
 set word [string tolower $word]
 set fp [open $learn_db r]
 set allEntrys ""
 set count 1
 while {![eof $fp]} {
  gets $fp curEntry
  if {![string equal -nocase [lindex [split $curEntry] 1] $word] || ($count != $num && $num != -2)} {
   if {[info exists curEntry]&&$curEntry!=""} {lappend allEntrys $curEntry}
   if {[string equal -nocase [lindex [split $curEntry] 1] $word]} {incr count}
  } else {incr count;lappend allEntrys "$curEntry [join $text]"}
 }
 close $fp;set fp [open $learn_db w];foreach curEntry $allEntrys {puts $fp $curEntry};close $fp
}

proc learn_putEntry {word num text {whodid "."}} {
 global learn_db
 set word [string tolower $word]
 set fp [open $learn_db r]
 set allEntrys ""
 set count 1
 if {$num==1} {lappend allEntrys "$whodid $word [join $text]"}
 while {![eof $fp]} {
  gets $fp curEntry
  if {[string equal -nocase [lindex [split $curEntry] 1] $word]} {incr count}
  if {[info exists curEntry]&&$curEntry!=""} {lappend allEntrys $curEntry}
  if {$count==$num&&$num!=1} {lappend allEntrys "$whodid $word [join $text]"}
 }
 close $fp;set fp [open $learn_db w];foreach curEntry $allEntrys {puts $fp $curEntry};close $fp
}
  

proc learn_repEntry {word num text} {
 global learn_db
 set word [string tolower $word]
 set fp [open $learn_db r]
 set allEntrys ""
 set count 1
 while {![eof $fp]} {
  gets $fp curEntry
  if {![string equal -nocase [lindex [split $curEntry] 1] $word] || ($count != $num && $num != -2)} {
   if {[info exists curEntry]&&$curEntry!=""} {lappend allEntrys $curEntry}
   if {[string equal -nocase [lindex [split $curEntry] 1] $word]} {incr count}
  } else {incr count;lappend allEntrys "[lrange [split $curEntry] 0 1] [join $text]"}
 }
 close $fp;set fp [open $learn_db w];foreach curEntry $allEntrys {puts $fp $curEntry};close $fp
}

proc learn_sortFile {a c d e f} {
 global learn_db
 set t_count [clock clicks -milliseconds]
 set fp [open $learn_db r]
 set allEntrys ""
 while {![eof $fp]} {
  set curEntry [gets $fp]
  if {[info exists curEntry]&&$curEntry!=""} {lappend allEntrys [split $curEntry " "]}
 }
 close $fp; set allEntrys [lsort -index 1 $allEntrys]
 set fp [open $learn_db w];foreach curEntry $allEntrys {puts $fp [join $curEntry " "]};close $fp
 putlog "!learn \[by Hal9000@PTnet\]-> Done with sorting of data on the database ($learn_db)->[expr double([clock clicks -milliseconds]-$t_count)/1000]s"
}
bind time - "12 * * * *" learn_sortFile

proc learn_filterstr { data } {
 regsub -all -- \\\\ $data \\\\\\\\ data
 regsub -all -- \\\[ $data \\\\\[ data	
 regsub -all -- \\\] $data \\\\\] data
 regsub -all -- \\\} $data \\\\\} data
 regsub -all -- \\\{ $data \\\\\{ data
 regsub -all -- \\\" $data \\\\\" data
 return $data
}

proc learn_search { nick uhost hand chan args } {
 global learn_db
 set args [string tolower [lindex $args 0]]
 if {$args==""} {puthelp "PRIVMSG $chan :Not enough arguments.";return}
 set init_t [clock clicks -milliseconds]
 set fp [open $learn_db r];set matches "";set allEntrys ""
 while {![eof $fp]} {
  gets $fp curEntry;if {[info exists curEntry]&&$curEntry!=""} {
   set curEntry [split [string tolower $curEntry] " "]; set thisEntry [join [lrange $curEntry 1 end] " "]
   if {[string match -nocase "*${args}*" $thisEntry]} {
#    putserv "PRIVMSG #meta :worked $curEntry"
    if {[lsearch $allEntrys [lindex curEntry 1]]==-1} {lappend allEntrys [lindex $curEntry 1];set allEntrys [lsort -unique $allEntrys]}
 } } } ;set init_t [expr double(([clock clicks -milliseconds] - $init_t))/1000]
 if {$allEntrys==""} {puthelp "PRIVMSG $chan :Sorry, no matches for $args on the defenition database. (\002\037${init_t}\037s)"
 } else {
  if {[llength $allEntrys]>10} {puthelp "PRIVMSG $chan :\002Too much matches.\002 Please try a more complex search."
  } else {puthelp "PRIVMSG $chan :\002Found \037[llength $allEntrys]\037 matches.\002 Sorted: \037[join [lsort -dictionary $allEntrys] "\037, \037"]\037. (\002\037${init_t}\037s)"
  }
 }
}

