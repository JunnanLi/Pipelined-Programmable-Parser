sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 7430557.566980
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_example.rc" \
           -overWriteAutoAlias on -appendSignals on
wvSetCursor -win $_nWave2 15087579.913133 -snap {("G1" 6)}
srcActiveTrace \
           "Testbench_wrapper.StreamParser_Top.parser_top.w_meta_layer3\[520:0\]" \
           -win $_nTrace1 -TraceByDConWave -TraceTime 14500000 -TraceValue \
           00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
srcHBSelect \
           "Testbench_wrapper.StreamParser_Top.parser_top.parser_layer3.lookup_type" \
           -win $_nTrace1
srcSetScope -win $_nTrace1 \
           "Testbench_wrapper.StreamParser_Top.parser_top.parser_layer3.lookup_type" \
           -delim "."
srcHBSelect \
           "Testbench_wrapper.StreamParser_Top.parser_top.parser_layer3.lookup_type" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "test1" -line 38 -pos 1 -win $_nTrace1
srcSelect -signal "test2" -line 41 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "test1" -line 38 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
debExit
