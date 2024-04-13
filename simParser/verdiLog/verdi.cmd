sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
<<<<<<< HEAD
wvSetCursor -win $_nWave2 4578451.715882
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_deparser.rc" \
           -overWriteAutoAlias on -appendSignals on
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 15152648.468587 -snap {("G3" 5)}
wvSetCursor -win $_nWave2 15754906.010733 -snap {("G3" 6)}
debExit
=======
wvSetCursor -win $_nWave2 6855757.575758
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_deparser.rc" \
           -overWriteAutoAlias on -appendSignals on
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 11247697.468954 14599511.314702
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetCursor -win $_nWave2 12536912.448146 -snap {("G1" 4)}
wvSetMarker -win $_nWave2 -keepViewRange -name "1st_pkt" 12500000.000000 \
           ID_GREEN5 long_dashed
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 13111509.107417 -snap {("G2" 1)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 13715125.799985 -snap {("G2" 5)}
wvSetCursor -win $_nWave2 14327448.502541 -snap {("G2" 6)}
wvSetCursor -win $_nWave2 13915364.029731 -snap {("G2" 6)}
wvSetCursor -win $_nWave2 13729635.816633 -snap {("G2" 5)}
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSetCursor -win $_nWave2 14286820.455927 -snap {("G2" 6)}
>>>>>>> three_stage_parser
