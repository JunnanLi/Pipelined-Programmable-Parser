sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sverilog" "+v2k" "-f" "file_list.f" "-top" "Testbench_wrapper"
debLoadSimResult \
           /home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/wave.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 2311078.928313
wvRestoreSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test.rc" \
           -overWriteAutoAlias on -appendSignals on
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 8103265.432847 -snap {("G6" 2)}
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvScrollUp -win $_nWave2 6
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvScrollUp -win $_nWave2 2
wvScrollUp -win $_nWave2 2
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectGroup -win $_nWave2 {G1}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
wvSelectSignal -win $_nWave2 {( "G4" 2 )} 
wvSelectGroup -win $_nWave2 {G5}
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvScrollDown -win $_nWave2 4
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvScrollUp -win $_nWave2 4
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSelectGroup -win $_nWave2 {G2}
wvSetPosition -win $_nWave2 {("G2" 0)}
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top" -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.parser_layer" -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.parser_layer" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcHBSelect "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" \
           -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_phv_valid" -line 26 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvRenameGroup -win $_nWave2 {G2} {extract_type}
wvSelectGroup -win $_nWave2 {G3}
wvRenameGroup -win $_nWave2 {G3} {extract_key}
wvSelectGroup -win $_nWave2 {G4}
wvSelectSignal -win $_nWave2 {( "extract_key" 3 )} 
wvSelectSignal -win $_nWave2 {( "extract_key" 2 )} 
wvSelectSignal -win $_nWave2 {( "extract_key" 1 )} 
wvSelectSignal -win $_nWave2 {( "extract_type" 3 )} 
wvSelectSignal -win $_nWave2 {( "extract_type" 2 )} 
wvSelectSignal -win $_nWave2 {( "extract_type" 1 )} 
wvSelectSignal -win $_nWave2 {( "extract_key" 1 )} 
wvSelectSignal -win $_nWave2 {( "extract_key" 2 )} 
wvSetCursor -win $_nWave2 8300032.832178 -snap {("extract_key" 1)}
wvSetCursor -win $_nWave2 8113319.241572 -snap {("extract_key" 1)}
wvSelectSignal -win $_nWave2 {( "extract_key" 3 )} 
wvSelectGroup -win $_nWave2 {G4}
wvSelectSignal -win $_nWave2 {( "G4" 2 )} 
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
wvSelectSignal -win $_nWave2 {( "G4" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvScrollDown -win $_nWave2 4
wvSelectGroup -win $_nWave2 {G6}
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvScrollDown -win $_nWave2 4
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvScrollDown -win $_nWave2 3
wvScrollUp -win $_nWave2 3
wvSelectGroup -win $_nWave2 {extract_key}
wvSelectGroup -win $_nWave2 {G4}
wvSelectSignal -win $_nWave2 {( "G4" 2 )} 
wvSetCursor -win $_nWave2 8103265.432847 -snap {("G4" 2)}
srcActiveTrace \
           "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer.i_pkt\[133:0\]" \
           -win $_nTrace1 -TraceByDConWave -TraceTime 8100000 -TraceValue \
           00111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
wvScrollUp -win $_nWave2 8
wvScrollDown -win $_nWave2 0
wvSelectGroup -win $_nWave2 {G1}
wvRenameGroup -win $_nWave2 {G1} {lookup_type}
wvSelectGroup -win $_nWave2 {G4}
wvScrollDown -win $_nWave2 3
wvScrollUp -win $_nWave2 3
wvScrollDown -win $_nWave2 3
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
wvSelectSignal -win $_nWave2 {( "G4" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSelectGroup -win $_nWave2 {G5}
wvRenameGroup -win $_nWave2 {G5} {gen_PHV}
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 2
wvSelectSignal -win $_nWave2 {( "gen_PHV" 1 )} 
wvSelectSignal -win $_nWave2 {( "gen_PHV" 2 )} 
wvSelectGroup -win $_nWave2 {G6}
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 2
wvSelectSignal -win $_nWave2 {( "G6" 8 )} 
wvSelectSignal -win $_nWave2 {( "G6" 7 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvSelectGroup -win $_nWave2 {G6}
wvRenameGroup -win $_nWave2 {G6} {head_shift}
wvSelectSignal -win $_nWave2 {( "head_shift" 3 )} 
wvSelectSignal -win $_nWave2 {( "extract_key" 3 )} 
wvSelectSignal -win $_nWave2 {( "gen_PHV" 2 )} 
wvSetPosition -win $_nWave2 {("gen_PHV" 2)}
srcHBSelect "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" -win $_nTrace1
srcSetScope -win $_nTrace1 "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" \
           -delim "."
srcHBSelect "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_meta" -line 28 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 7908221.543582 -snap {("gen_PHV" 3)}
wvSetCursor -win $_nWave2 7899603.993247 -snap {("gen_PHV" 3)}
srcActiveTrace \
           "Testbench_wrapper.HyPipe_Top.gen_PHV_and_conf_parer.o_meta\[520:0\]" \
           -win $_nTrace1 -TraceByDConWave -TraceTime 7100000 -TraceValue \
           00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
srcDeselectAll -win $_nTrace1
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcDeselectAll -win $_nTrace1
srcSelect -word -line 107 -pos 17 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -word -line 111 -pos 14 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_meta" -line 112 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_meta" -line 111 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_meta" -line 110 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_meta" -line 109 -pos 1 -win $_nTrace1
wvSetCursor -win $_nWave2 8097807.650967 -snap {("gen_PHV" 3)}
wvSetCursor -win $_nWave2 7903912.768414 -snap {("gen_PHV" 3)}
wvSetCursor -win $_nWave2 7708581.627473 -snap {("G4" 1)}
wvSetCursor -win $_nWave2 7909657.801972 -snap {("gen_PHV" 3)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSaveSignal -win $_nWave2 \
           "/home/lijunnan/Documents/0-code/vcs_prj/Programmable-Parser/test.rc"
debExit
