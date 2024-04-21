sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 3621200.311769
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_decap.rc" \
           -overWriteAutoAlias on -appendSignals on
wvZoom -win $_nWave2 9320654.715511 12752922.837101
wvSetCursor -win $_nWave2 10404106.460829 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 10631497.567871 -snap {("G1" 6)}
debReload
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 18704924.946342 26152652.499348
wvZoom -win $_nWave2 20074888.861000 22112419.937466
wvSetCursor -win $_nWave2 20807002.521367 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 21002338.704068 -snap {("G1" 6)}
