sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 5045969.672785
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_example.rc" \
           -overWriteAutoAlias on -appendSignals on
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 9706101.614704 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 9921275.413071 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 10095740.654990 -snap {("G1" 6)}
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetCursor -win $_nWave2 9700286.106640 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 10101556.163054 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 9697378.352608 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 10104463.917086 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 10709276.755738 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 10921542.800073 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 11119270.074248 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 10927358.308137 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 10723815.525898 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 9915459.905007 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 10729631.033962 -snap {("G1" 6)}
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvSetCursor -win $_nWave2 10116094.933214 -snap {("G1" 7)}
wvSetCursor -win $_nWave2 10308006.699325 -snap {("G1" 7)}
wvSetCursor -win $_nWave2 10485379.695276 -snap {("G1" 7)}
wvSetCursor -win $_nWave2 10697645.739610 -snap {("G1" 7)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSetCursor -win $_nWave2 8932639.042197 -snap {("G1" 2)}
wvSetCursor -win $_nWave2 9485112.308273 -snap {("G1" 2)}
wvSetCursor -win $_nWave2 10113187.179182 -snap {("G1" 3)}
wvSetCursor -win $_nWave2 10709276.755738 -snap {("G1" 4)}
debExit
