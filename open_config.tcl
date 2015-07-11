::cisco::eem::event_register_syslog occurs 1 pattern $_syslog_pattern maxrun 240
#------------------------------------------------------------------
#
#event manager environment _config_name 3.txt 				 ----- target config file
#event manager environment _config_path disk0a:/usr/		       	----- config file path
#event manager environment _syslog_pattern %MGBL-SYS-5-CONFIG_I		 ----- trigger of this TCL script
#event manager directory user policy disk0a:/tcl			  ----- script stored path
#event manager policy open_config.tcl username cisco persist-time 3600	 ----- register this script 
#
# For more details of EEM setup, please refer to the link below:
# http://www.cisco.com/en/US/docs/routers/asr9000/software/asr9k_r4.1/system_monitoring/configuration/guide/sysmon_cg41asr9k_chapter2.html#con_1046664
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



if { ! [info exists _syslog_pattern] } { 

	error "Enviornment variable _syslog_pattern is NOT set."
	exit 1

	}

if { ! [info exists _config_path] } { 

	error "Environment variable _config_path is NOT set"
	exit 1
	
	}

if { ! [info exists _config_name]  } { 

	error "Environment variable _config_name is NOT set"
	exit 1

	}

set full_name $_config_path$_config_name

file delete $full_name

puts "Saving running config to $full_name...." 

if [catch {cli_open} result] {
    return -code error $result
} else {
    array set cli1 $result
} 

puts "Executing copy..."

#if [catch {cli_exec $cli1(fd) "show running-config"} result] {
#    return -code error $result
#}

#puts $result

puts "Executing copy..."
if [catch {cli_write $cli1(fd) "copy running-config $full_name"} result] {
    return -code error $result
}

puts "111111111111111"
if [catch {cli_read_pattern $cli1(fd) "Destination file name"} result] {
    return -code error $result
}

puts "222222222222222"
if [catch {cli_write $cli1(fd) $full_name} result] {
    return -code error $result
}

if [catch {cli_read_pattern $cli1(fd) "#"} result] {
    return -code error $result
}

if [catch {cli_close $cli1(fd) $cli1(tty_id)} result] {
    return -code error $result
}

puts "Done!"

if { ! [file exists $full_name] } { 

	error "Configuration file DOES NOT exists."
	exit 1

	}

set fid [open $full_name r]

set new_config ""
set parse_stop 1

while { [gets $fid each_line] >= 0 } { 
	if { $parse_stop } { 

		if { [regexp {^\sshutdown$} $each_line ] } { 
			continue
		}
		if { [regexp {^interface\s(GigabitEthernet|TenGigE)[0-7]/[0-9]+/[0-9]+/[0-9]+$} $each_line ] } {
			append new_config $each_line "\n" " shutdown\n"
			continue
		} 
		if { [regexp {^router.*} $each_line ] } { 
			set parse_stop  0			
		}
		append new_config $each_line "\n"
	} else { 
		append new_config $each_line "\n"
	}	

}

close $fid
#puts "Closed file handler!"
#puts "Deleted old saved config file."
file delete $full_name


#puts "Recreated config file. "
set new_fid [open $full_name w+]
#puts "Fill it out with updated config commands."
puts $new_fid $new_config
close $new_fid
