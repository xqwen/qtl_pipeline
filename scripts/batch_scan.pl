@files = <sbams_data/*.dat>;
foreach $f (@files){

    $f =~/(ENSG\d+)/;
    print "dap-g -d $f -scan > scan_out/$1.bf\n";
}
