import pandas as pd
from get_type import *
path = './eht_ipv4_tcp.parserTree.csv'
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
	print("idx:",idx)
	temp_layer_info = {}
	layer_name = list_head_notnull[idx]
	temp_layer_info.update({"name":layer_name})
	temp_layer_info.update({"head_len":data['offset'][list_index_notnull[idx+1]]-data['offset'][list_index_notnull[idx]]})
	temp_layer_info.update({"meta_len":data['key'][list_index_notnull[idx]]})
	# get type info
	temp_type_info = get_type_info(data, list_index_notnull, idx)
	temp_layer_info.update({"type":temp_type_info})
	# get keyfield info
	temp_key_info = get_key_info(data, list_index_notnull, idx)
	temp_layer_info.update({"keyField":temp_key_info})
	layer_info.append(temp_layer_info)
	dbg_print("temp_layer_info:",temp_layer_info)
	print("layer_info:",layer_info)
