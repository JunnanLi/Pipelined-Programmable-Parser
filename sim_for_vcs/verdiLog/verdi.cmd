sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
nsMsgSwitchTab -tab general
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
nsMsgSwitchTab -tab cmpl
srcHBSelect "Testbench_wrapper.parser_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.parser_top" -delim "."
srcHBSelect "Testbench_wrapper.parser_top" -win $_nTrace1
wvSelectGroup -win $_nWave2 {G1}
srcDeselectAll -win $_nTrace1
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_clk" -line 28 -pos 1 -win $_nTrace1
srcSelect -signal "i_rst_n" -line 29 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvSetPosition -win $_nWave2 {("G2" 0)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "layer_info_0" -line 47 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {47 47 4 4 11 12}
srcDeselectAll -win $_nTrace1
srcSelect -signal "layer_info_1" -line 47 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvSetPosition -win $_nWave2 {("G2" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "layer_info_0" -line 47 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 1)}
srcHBSelect "Testbench_wrapper.parser_top.parser_layer1" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.parser_top.parser_layer1" -delim \
           "."
srcHBSelect "Testbench_wrapper.parser_top.parser_layer1" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSearchString "slice_id" -win $_nTrace1 -next -case
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "slice_id" -line 205 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 10519740.259740 -snap {("G3" 1)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_valid_head" -line 212 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_start" -line 207 -pos 1 -win $_nTrace1
srcSelect -signal "tag_valid_head" -line 212 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 9977575.757576 -snap {("G3" 3)}
wvSetCursor -win $_nWave2 10607186.147186 -snap {("G3" 4)}
wvSetCursor -win $_nWave2 10362337.662338 -snap {("G3" 4)}
debExit
