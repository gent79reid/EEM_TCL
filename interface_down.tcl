::cisco::eem::event_register_syslog occurs 1 pattern $_syslog_pattern_ipsla_down maxrun 240
#------------------------------------------------------------------
#This solution includes two scripts, interface_down.tcl(shutdown the dedicated interface) & interface_up.tcl(no shut the interface)
#
#event manager environment _config_interface [the dedicated interface] 	     ----- target config interface
#event manager environment _syslog_pattern_ipsla_down %MGBL-IPSLA-5-THRESHOLD_SET : Monitor element has exceeded the threshold condition.		 ----- trigger of interface_down.tcl script
#event manager environment _syslog_pattern_ipsla_up %MGBL-IPSLA-5-THRESHOLD_CLEAR : Monitor element has reset the threshold reaction.		 ----- trigger of interface_up.tcl script
#event manager directory user policy disk0:			     ----- script stored path
#event manager policy interface_down.tcl username cisco	 ----- register interface_down.tcl script 
#event manager policy interface_up.tcl username cisco	 ----- register interface_up.tcl script 
#
# For more details of EEM setup, please refer to the link below:
# http://www.cisco.com/en/US/docs/routers/asr9000/software/asr9k_r4.1/system_monitoring/configuration/guide/sysmon_cg41asr9k_chapter2.html#con_1046664
# 
#01/14/2012, Yong Ha , Cisco Systems
#
# Copyright (c) 2012 by cisco Systems, Inc.
# All rights reserved.
#------------------------------------------------------------------
### 
###


namespace import ::cisco::eem::*
namespace import ::cisco::lib::*

if { ! [info exists _config_interface] } { 

	error "Enviornment variable _config_interface is NOT set."
	exit 1

	}

if { ! [info exists _syslog_pattern_ipsla_down] } { 

	error "Environment variable _syslog_pattern_ipsla_down is NOT set"
	exit 1
	
	}
	
#################################################################################


if [catch {cli_open} result] {
    error $result $errorInfo
} else {
    array set cli1 $result
    }
if [catch {cli_exec $cli1(fd) "enable"} result] {
    error $result $errorInfo
}
if [catch {cli_exec $cli1(fd) "config t"} result] {
    error $result $errorInfo
}
if [catch {cli_exec $cli1(fd) "interface $_config_interface"} result] {
        error $result $errorInfo
}        
if [catch {cli_exec $cli1(fd) "shut"} result] {
        error $result $errorInfo
    } else {
	    puts "The IP SLA status become down, the interface $_config_interface has been shutdown via EEM"
	}

if [catch {cli_exec $cli1(fd) "exit"} result] {
	error $result $errorinfo
} 

if [catch {cli_exec $cli1(fd) "commit"} result] {
    error $result $errorinfo
} 

if [catch {cli_exec $cli1(fd) "end"} result] {
    error $result $errorinfo
}