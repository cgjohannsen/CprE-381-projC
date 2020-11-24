vcom -work work tb_pipelineReg.vhd
vsim -voptargs="+acc" work.tb_pipelineReg
add wave sim:/tb_pipelineReg/*