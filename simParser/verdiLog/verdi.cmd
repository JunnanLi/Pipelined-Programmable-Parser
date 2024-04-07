sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 4256025.538707
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_example.rc" \
           -overWriteAutoAlias on -appendSignals on
debExit
