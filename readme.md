StreamParser - A Programmable Parser/Deparser in stream mode
======================================

#### Table of Contents
  - [Table of Contents](#table-of-contents)
  - [Files in this Repository](#files-in-this-repository)
  - [Simulation](#simulation)
  - [Source code](#source-code)


Files in this Repository
------------------------

| Name            | Description                           |
|-----------------|---------------------------------------|
| c-based_parser  | parser simulation in c program        |
| python-gen_rule | generate parser rule in python script |
| sim_for_vcs     | simulation env for vcs                |
| src             | source code                           |

Simulation
------------------------

- using python script to generate parser rules
```bash
	cd python-gen_rule
	python3 read_csv.py
```
- or using following command to generate deparser rules
```bash
	cd python-gen_rule
	python3 read_csv.py ./eth_ipv4_tcp.deparserTree.csv deparser
```
- simulation in vcs
```bash
	cd sim_for_vcs
	make clean; make com; make sim; make verdi
```
- simulation with c-based checkor is on the way

Source code
------------------------


#### Files in source code

| Name            | Description                                            |
|-----------------|--------------------------------------------------------|
| bench_rtl       | test benches                                           |
| rtl             | parser, deparser, capsulation, decapsulation code      |
| sim_rtl         | fifo, sram module for simulation                       |
| soc_rtl         | top module used to connect with 128b FAST's pkt format |