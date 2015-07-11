#::cisco::eem::event_register_timer countdown time $_countdown_time maxrun 600
::cisco::eem::event_register_none maxrun 600
#------------------------------------------------------------------
#
#event manager environment _countdown_time 1200
#event manager policy countdown.tcl username cisco persist-time 3600
# 
#Christmas Eve 2011, Reid Cheng , Cisco Systems
#
# Copyright (c) 2011 by cisco Systems, Inc.
# All rights reserved.
#------------------------------------------------------------------
### 
###

namespace import ::cisco::eem::*
namespace import ::cisco::lib::*

puts "countdown.tcl script is running ....."

if { ! [info exists _countdown_time] } { 
	error "global environment variable _countdown_time is not set"
	exit 1
}

if [catch {cli_open} result] {
    error $result $errorinfo
} else {
    array set cli1 $result
} 

if [catch {cli_exec $cli1(fd) "show interface brief"} show_result] {
    error $show_result $errorinfo
} 

#parse the output of "show interface brief" command to list out the main interfaces which is in "admin-shutdown" status. 

set if_list [split $show_result "\n"]
set matched ""
set match_1 ""
set match_2 ""
set target_if_list {} 

foreach if_item $if_list { 
	if { [regexp {^\s+(Gi|Te)([0-7]/[0-9]+/[0-9]+/[0-9]+)\s+admin-down\s+admin-down} $if_item matched match_1 match_2] } { 
		lappend target_if_list $match_1$match_2
	}
}


if { [llength $target_if_list] == 0 } { 
	puts "*********************************************"
	puts "*********no admin-shutdown interface*********"
	puts "*********************************************"
	exit 0
}

puts "***************************************************************"

if [catch {cli_exec $cli1(fd) "config t"} result] {
    error $result $errorinfo
} 
#No shut "admin-shutdown" interface
foreach tif_item $target_if_list { 
	puts "$tif_item ......"
	if [catch {cli_exec $cli1(fd) "interface $tif_item"} result] {
		error $result $errorinfo
	}
	puts "no shutdown"
	if [catch {cli_exec $cli1(fd) "no shutdown"} result] {
		error $result $errorinfo
	}
	puts "exit"
	if [catch {cli_exec $cli1(fd) "exit"} result] {
	        error $result $errorinfo
	} 
	
}


#commit the changes
if [catch {cli_exec $cli1(fd) "commit"} result] {
    error $result $errorinfo
} 
puts "commit"
#exit config mode
if [catch {cli_exec $cli1(fd) "end"} result] {
    error $result $errorinfo
}
puts "end"




