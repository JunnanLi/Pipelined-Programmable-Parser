sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 5800503.778338
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test_deparser.rc" \
           -overWriteAutoAlias on -appendSignals on
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 10464651.553317 -snap {("G1" 20)}
wvSelectSignal -win $_nWave2 {( "G1" 20 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSetCursor -win $_nWave2 10142401.343409 -snap {("G2" 1)}
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSelectGroup -win $_nWave2 {G2}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
srcHBSelect "Testbench_wrapper.deparser_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.deparser_top" -delim "."
srcHBSelect "Testbench_wrapper.deparser_top" -win $_nTrace1
srcHBSelect "Testbench_wrapper.deparser_top.deparser_layer1" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.deparser_top.deparser_layer1" \
           -delim "."
srcHBSelect "Testbench_wrapper.deparser_top.deparser_layer1" -win $_nTrace1
srcHBSelect "Testbench_wrapper.deparser_top.deparser_layer1.shift_replace_head" \
           -win $_nTrace1
srcSetScope -win $_nTrace1 \
           "Testbench_wrapper.deparser_top.deparser_layer1.shift_replace_head" \
           -delim "."
srcHBSelect "Testbench_wrapper.deparser_top.deparser_layer1.shift_replace_head" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcDeselectAll -win $_nTrace1
srcSelect -signal "r_startBit_metaTag" -line 78 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 10345927.791772 -snap {("G2" 3)}
wvSelectSignal -win $_nWave2 {( "G1" 20 )} 
