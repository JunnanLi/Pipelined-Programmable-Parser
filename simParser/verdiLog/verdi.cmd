sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 2636661.911555
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test.rc" \
           -overWriteAutoAlias on -appendSignals on
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSetCursor -win $_nWave2 7126186.631791 -snap {("G2" 1)}
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.parser_layer" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_meta_valid" -line 43 -pos 1 -win $_nTrace1
srcSelect -signal "o_meta" -line 44 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
debExit
