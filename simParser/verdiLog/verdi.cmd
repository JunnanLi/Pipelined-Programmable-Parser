sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 2853471.667997
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_example.rc" \
           -overWriteAutoAlias on -appendSignals on
wvSetCursor -win $_nWave2 13115152.441797 -snap {("G1" 9)}
wvSetMarker -win $_nWave2 -keepViewRange -name "1st_pkt" 13100000.000000 \
           ID_GREEN5 long_dashed
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetCursor -win $_nWave2 15713230.669377 -snap {("G1" 7)}
wvSaveSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_example.rc"
debExit
