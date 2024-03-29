sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
nsMsgSwitchTab -tab general
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
nsMsgSwitchTab -tab cmpl
srcDeselectAll -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.parser_layer" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_head" -line 37 -pos 1 -win $_nTrace1
srcSelect -signal "i_meta" -line 39 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoom -win $_nWave2 965335.235378 2190014.265335
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 1355707.456843 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 1229920.167033 -snap {("G1" 1)}
srcActiveTrace "Testbench_wrapper.HyPipe_Top.parser_layer.i_head\[546:0\]" -win \
           $_nTrace1 -TraceByDConWave -TraceTime 0 -TraceValue \
           xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_pkt_valid" -line 49 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_pkt_valid" -line 56 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 3)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_phv\[PHV_WIDTH-1-128*i-:128\]" -line 63 -pos 1 -win \
          $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_phv_valid" -line 66 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 5939955.352146 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 1942714.809290 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 2445863.968531 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 7449402.829868 -snap {("G1" 4)}
srcActiveTrace "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer.o_phv_valid" \
           -win $_nTrace1 -TraceByDConWave -TraceTime 200000 -TraceValue 0
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_pkt\[133:132\]" -line 66 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_pkt\[133:132\]" -line 66 -pos 1 -win $_nTrace1
srcAction -pos 65 12 3 -win $_nTrace1 -name "o_pkt\[133:132\]" -ctrlKey off
srcBackwardHistory -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.parser_layer" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" \
           -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_pkt" -line 18 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetCursor -win $_nWave2 1453542.015584 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 2348029.409790 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 3074800.417582 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 5730309.869129 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 6289364.490508 -snap {("G1" 4)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_phv\[8+:8\]" -line 54 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_phv\[PHV_WIDTH-1-:128\]" -line 53 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_phv" -line 52 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_phv\[0+:PHV_WIDTH\]" -line 51 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "r_cnt_pkt" -line 50 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "r_cnt_pkt" -line 59 -pos 1 -win $_nTrace1
debExit
