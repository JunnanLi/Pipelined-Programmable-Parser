sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 6199529.042386
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test.rc" \
           -overWriteAutoAlias on -appendSignals on
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.parser_layer" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer.lookup_type" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "Testbench_wrapper.HyPipe_Top.parser_layer.lookup_type" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer.lookup_type" -win \
           $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_result" -line 20 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSelectSignal -win $_nWave2 {( "G2" 4 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G2" 3)}
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.parser_layer" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_meta" -line 44 -pos 1 -win $_nTrace1
srcSelect -signal "o_meta_valid" -line 43 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 6271040.912441 -snap {("G2" 4)}
srcActiveTrace "Testbench_wrapper.HyPipe_Top.parser_layer.o_meta\[127:0\]" -win \
           $_nTrace1 -TraceByDConWave -TraceTime 1900000 -TraceValue \
           10001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000
srcDeselectAll -win $_nTrace1
srcSelect -word -line 130 -pos 18 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_key_field\[idx\]" -line 132 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 5 )} 
wvSelectSignal -win $_nWave2 {( "G2" 6 )} 
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G2" 5 )} 
wvSelectSignal -win $_nWave2 {( "G2" 6 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G2" 5)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_key_field\[idx\]" -line 132 -pos 1 -win $_nTrace1
srcAction -pos 131 30 4 -win $_nTrace1 -name "w_key_field\[idx\]" -ctrlKey off
srcShowCalling -win $_nTrace1
srcSelect -win $_nTrace1 -range {89 89 2 3 1 1}
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer.gen_extract_field\[0\]" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_key_field\[idx\]" -line 93 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_key_field\[idx\]" -line 93 -pos 1 -win $_nTrace1
srcSearchString "w_key_field" -win $_nTrace1 -prev -case
srcSelect -win $_nTrace1 -range {52 52 29 30 1 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_key_field" -line 52 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 6 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G2" 6)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_typeRule_wren" -line 54 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_key_offset" -line 53 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_key_field" -line 52 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_key_offset" -line 53 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 6 )} 
wvSelectSignal -win $_nWave2 {( "G2" 7 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G2" 6)}
debExit
                                                                                                                                                                                     debExit
