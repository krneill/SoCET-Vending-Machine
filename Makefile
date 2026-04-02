VERILATE := verilator
VERILATE_FLAGS := --binary --trace-fst

vending_machine: src/vending_machine.sv tb/tb_vending_machine.sv
	$(VERILATE) $(VERILATE_FLAGS) --top-module tb_vending_machine $^
	cp obj_dir/Vtb_vending_machine .

clean:
	rm -rf obj_dir
	rm -f Vtb_vending_machine
	rm -f waveform.fst