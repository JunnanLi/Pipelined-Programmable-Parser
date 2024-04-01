sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 3515549.215407
wvSetCursor -win $_nWave2 3529957.203994
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test.rc" \
           -overWriteAutoAlias on -appendSignals on
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G5" 6 )} 
wvSelectGroup -win $_nWave2 {G6}
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectGroup -win $_nWave2 {G6}
wvSetPosition -win $_nWave2 {("G6" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_data_valid" -line 47 -pos 1 -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.parser_layer" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer.shift_head" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.parser_layer.shift_head" \
           -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer.shift_head" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {98 99 4 1 1 1}
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 3865766.301927 25035438.907717
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoom -win $_nWave2 5994813.261567 8939239.907879
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 7509029.817907 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 7290613.005342 -snap {("G5" 6)}
wvSetCursor -win $_nWave2 6725249.486664 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 8300370.731125 -snap {("G5" 5)}
wvSelectSignal -win $_nWave2 {( "G5" 5 )} 
wvSetCursor -win $_nWave2 8514587.220371 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 8669999.183158 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 8497785.927097 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 8712002.416344 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 8514587.220371 -snap {("G5" 5)}
debExit
