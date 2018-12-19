
#scale 0.05 second = 1 minute

set ns [new Simulator]
$ns rtproto DV
set nf [open output.nam w]
$ns namtrace-all $nf
set tracefd [open result.tr w]
$ns trace-all $tracefd
proc finish {} {
global ns nf
$ns flush-trace
close $nf
exec nam output.nam &
exit 0
}

#node creation

for {set i 0} {$i < 50} {incr i} {

		set n([expr ($i)]) [$ns node]
	
}

#street coordinators - 4,9,14...49

#node 50 is central coordinator
set n(50) [$ns node]
set null(50) [new Agent/Null]
$ns attach-agent $n(50) $null(50)


for {set i 0} {$i < 186} {incr i} {
set udp([expr ($i)]) [new Agent/UDP]
}

for {set i 4} {$i < 50} {incr i 5} {
	
	for {set j 1} {$j < 5} {incr j}  {
		$ns duplex-link $n([expr $i]) $n([expr ($i-$j)]) 1Mb 10ms DropTail

		#40 udp agents created at street coordinators
		set udp([expr ($i)]) [new Agent/UDP]
		$ns attach-agent $n([expr $i]) $udp([expr ($i-$j)])
		set cbr([expr ($i-$j)]) [new Application/Traffic/CBR]
		$cbr([expr ($i-$j)]) set packetSize_ 1500
		$cbr([expr ($i-$j)]) set interval_ 1.5
		$cbr([expr ($i-$j)]) attach-agent $udp([expr ($i-$j)])
		
		#packets sent every 30 mins to every lamppost
		set null([expr ($i-$j)]) [new Agent/Null]
		$ns attach-agent $n([expr ($i-$j)]) $null([expr ($i-$j)])
		$ns connect $udp([expr ($i-$j)]) $null([expr ($i-$j)])
		$ns at 0.5 "$cbr([expr ($i-$j)]) start"
		$ns at 6.5 "$cbr([expr ($i-$j)]) stop"
	}
		
}

for {set i 4} {$i < 50} {incr i 5} {
	$ns duplex-link $n(50) $n([expr ($i)]) 1Mb 10ms DropTail
	
	# udp link to central coordinator from street coordinators
	set udp([expr 50+$i]) [new Agent/UDP]
	$ns attach-agent $n([expr $i]) $udp([expr 50+$i])
	set cbr([expr (50+$i)]) [new Application/Traffic/CBR]
	$cbr([expr (50+$i)]) set packetSize_ 750
	$cbr([expr (50+$i)]) set interval_ 0.25
	$cbr([expr (50+$i)]) attach-agent $udp([expr (50+$i)])
	$ns connect $udp([expr 50+$i]) $null(50)
	$ns at 0.5 "$cbr([expr (50+$i)]) start"
	$ns at 6.5 "$cbr([expr (50+$i)]) stop"
	#sending packets of light sensor data every 5 mins
}

for {set i 4} {$i < 50} {incr i 5} {
	$ns duplex-link $n(50) $n([expr ($i)]) 1Mb 10ms DropTail
	
	#udp links of central coordinator
	set udp([expr 110+$i]) [new Agent/UDP]
	$ns attach-agent $n(50) $udp([expr 110+$i])
	set cbr([expr (110+$i)]) [new Application/Traffic/CBR]
	$cbr([expr (110+$i)]) set packetSize_ 1500
	$cbr([expr (110+$i)]) set interval_ 0.5
	$cbr([expr (110+$i)]) attach-agent $udp([expr (110+$i)])
	
	set null([expr 50+$i]) [new Agent/Null]
	$ns attach-agent $n([expr $i]) $null([expr 50+$i])

    #sending packets every 10 mins
	$ns connect $udp([expr 110+$i]) $null([expr 50+$i])
	$ns at 0.5 "$cbr([expr (110+$i)]) start"
	$ns at 6.5 "$cbr([expr (110+$i)]) stop"
	
}


$ns at 7.0 "finish"
$ns run



