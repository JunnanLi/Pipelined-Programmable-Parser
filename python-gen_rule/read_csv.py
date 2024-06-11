import pandas as pd
import sys
from get_type_key import *
from gen_rule import *
if len(sys.argv) > 2:
	path = sys.argv[1]
	mode = sys.argv[2]
elif len(sys.argv) > 1:
	path = sys.argv[1]
	mode = 'parser'
else:
	path = './eth_ipv4_tcp.parserTree.csv'
	mode = 'parser'
data = pd.read_csv(path)
#x = data[['header','B']]
#print(data)
#data_0 = data.head(2)
dbg_print(len(data))

# get list_head and index;
list_head = data['header']
list_head_notnull = list_head.dropna(axis=0, how='any')
list_index_notnull = list_head_notnull.index.values.tolist()
dbg_print(list_index_notnull)
list_head_notnull = list_head_notnull.tolist()
dbg_print(list_head_notnull)

layer_info = []
for idx in range(len(list_index_notnull)-1):
	dbg_print("idx:",idx)
	temp_layer_info = {}
	layer_name = list_head_notnull[idx]
	if idx == 0:
		first_layer_name = layer_name
	temp_layer_info.update({"name":layer_name})
	temp_layer_info.update({"head_len":data['len'][list_index_notnull[idx]]})
	temp_layer_info.update({"meta_len":data['meta_len'][list_index_notnull[idx]]})
	# get type info
	temp_type_info = get_type_info(data, list_index_notnull, idx)
	temp_layer_info.update({"type":temp_type_info})
	# get keyfield info
	temp_key_info = get_key_info(data, list_index_notnull, idx)
	temp_layer_info.update({"keyField":temp_key_info})
	layer_info.append(temp_layer_info)
	dbg_print("temp_layer_info:",temp_layer_info)
	dbg_print("layer_info:",layer_info)
dbg_print(first_layer_name)
print(layer_info)

# gen rules
rule_info = gen_rule_info(layer_info, first_layer_name)
# print(rule_info)
gen_testbench_w_rule(rule_info, mode)