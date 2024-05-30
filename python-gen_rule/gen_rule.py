# get type info
from get_type_key import *

def gen_rule_info(layer_info, first_layer_name):
	rule_info = []
	list_layer_wait2check = [{"name":first_layer_name}]
	list_next_layer_wait2check = []
	layerID = 0
	## gen first layer's rule
	cur_layer_name = first_layer_name
	# temp_rule_info = {}
	# temp_rule_info.update({"layerID":layerID})
	# temp_rule_info.update({"head_len":layer_info[0]['head_len']})
	# temp_rule_info.update({"meta_len":layer_info[0]['meta_len']})
	# ## get type's offset list
	# type_offset = list(range(int(layer_info[0]['type']['offset']),
	# 	int(layer_info[0]['type']['offset']+layer_info[0]['type']['len'])))
	# dbg_print(type_offset)
	# temp_rule_info.update({"type_offset":type_offset})
	# ## get keyField's offset list
	# keyField_offset = []
	# for i in range(len(layer_info[0]['keyField']['offset'])):
	# 	keyField_offset +=(list(range(int(layer_info[0]['keyField']['offset'][i]),
	# 		int(layer_info[0]['keyField']['offset'][i]+layer_info[0]['keyField']['len'][i]),2)))
	# dbg_print(keyField_offset)
	# temp_rule_info.update({"keyField_offset":keyField_offset})	
	# ## add next_type to list_layer_wait2check
	# for i in range(len(layer_info[0]['type']['proto'])):
	# 	list_next_layer_wait2check.append(layer_info[0]['type']['proto'][i][1])
	# list_layer_wait2check.remove(layer_info[0]['name'])
	# if not list_layer_wait2check:
	# 	list_layer_wait2check = list(set(list_next_layer_wait2check.copy()))
	# 	list_next_layer_wait2check.clear()
	# 	layerID +=1
	# print(list_layer_wait2check)

	# rule_info.append(temp_rule_info)

	while list_layer_wait2check:
		cur_layer_name = list_layer_wait2check[0]["name"]
		for idx in range(len(layer_info)):
			if layer_info[idx]['name'] == cur_layer_name:
				cur_idx = idx
				print(cur_layer_name)
		temp_rule_info = {}
		temp_rule_info.update({"layerID":layerID})
		temp_rule_info.update({"head_len":layer_info[cur_idx]['head_len']})
		temp_rule_info.update({"meta_len":layer_info[cur_idx]['meta_len']})
		
		## get type's value & mask
		typeValue_list = []
		typeMask_list = []
		if 'mask' in list_layer_wait2check[0]:
			if list_layer_wait2check[0]['mask'] > 255:
				typeMask_list = [list_layer_wait2check[0]['mask']>>8,list_layer_wait2check[0]['mask']%256]
				typeValue_list= [list_layer_wait2check[0]['value']>>8,list_layer_wait2check[0]['value']%256]
			else:
				typeMask_list = [list_layer_wait2check[0]['mask']]
				typeValue_list= [list_layer_wait2check[0]['value']]
		temp_rule_info.update({"typeMask":typeMask_list})
		temp_rule_info.update({"typeValue":typeValue_list})

		## get type's offset list
		type_offset = []
		if layer_info[cur_idx]['type']:
			type_offset += list(range(int(layer_info[cur_idx]['type']['offset']),
				int(layer_info[cur_idx]['type']['offset']+layer_info[cur_idx]['type']['len'])))	
			## add next_type to list_layer_wait2check
			for i in range(len(layer_info[cur_idx]['type']['proto'])):
				dir_next_type = {}
				dir_next_type.update({'name':layer_info[cur_idx]['type']['proto'][i][1]})
				dir_next_type.update({'mask':int(layer_info[cur_idx]['type']['mask'])})
				dir_next_type.update({'value':int(layer_info[cur_idx]['type']['proto'][i][0])})
				list_next_layer_wait2check.append(dir_next_type)
				## TODO, remove replicated protocol
		dbg_print(type_offset)
		temp_rule_info.update({"type_offset":type_offset})
		
		## get keyField's offset list
		keyField_offset = []
		if layer_info[cur_idx]['keyField']:
			for i in range(len(layer_info[cur_idx]['keyField']['offset'])):
				keyField_offset +=(list(range(int(layer_info[cur_idx]['keyField']['offset'][i]),
					int(layer_info[cur_idx]['keyField']['offset'][i]+layer_info[cur_idx]['keyField']['len'][i]),2)))
		dbg_print(keyField_offset)
		temp_rule_info.update({"keyField_offset":keyField_offset})

		## update list_layer_wait2check
		list_layer_wait2check.pop(0)
		if not list_layer_wait2check:
			list_layer_wait2check = list_next_layer_wait2check.copy()
			list_next_layer_wait2check.clear()
			layerID +=1
		print(list_layer_wait2check)
		rule_info.append(temp_rule_info)
		print(rule_info)
	return rule_info

