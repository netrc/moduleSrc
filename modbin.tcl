

# d - directory to list
# returns list { { f flink }* 
#
proc listExecs { d } {
  set eList {}
	if {! [file isdirectory $d] } {
		return $eList
	}
	foreach f [glob -nocomplain $d/*] {
		#puts stdout "... $f"
		if {[catch {set l [file link $f]} err]} {
			# not a link
			if [file executable $f] {
				lappend eList [list $f ""]
			}
		} else {
			# a link; 
			if {[string index $l 0] != "/"} {
				# a relative link; normalize it
				set l [file normalize [file dirname $f]/$l]
			}
			if [file executable $l] {
				lappend eList [list $f "-> $l"]
			} 
		}
	}
  return $eList
}

# m - name to search in PATH
# P - PATH value
# returns list { { pDir { { } } } }
proc listBin { m P } {
	set binList {}
	#puts stdout "listBin: $m"
	foreach p [split $P :] {
		#puts stdout "... $p"
		if [string match -nocase *$m* $p] {
				lappend binList [list $p [listExecs $p]]
		}
	}
	return $binList
}

proc tester {} {
		listBin foo
		listBin local
		listBin ric
}

set dirArg [lindex $argv 0]
foreach d [listBin $dirArg $env(PATH)] {
	puts stdout "# [lindex $d 0]"
	foreach ff [lindex $d 1] {
		set f [lindex $ff 0]
		set fl [lindex $ff 1]
		puts stdout "$f $fl"
	}
}
