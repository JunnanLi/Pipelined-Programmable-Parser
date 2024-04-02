sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 6231136.857350
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_example.rc" \
           -overWriteAutoAlias on -appendSignals on
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 11117110.419424 -snap {("G1" 6)}
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvSetCursor -win $_nWave2 9898241.411055 -snap {("G1" 9)}
wvSetMarker -win $_nWave2 -keepViewRange -name "1st_pkt" 9900000.000000 ID_GREEN5 \
           long_dashed
wvSetCursor -win $_nWave2 10507675.915240 -snap {("G1" 5)}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
debExit
