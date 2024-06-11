# get type info
from get_type_key import *

def gen_rule_info(layer_info, first_layer_name):
	rule_info = []
	list_layer_wait2check = [{"name":first_layer_name}]
	list_next_layer_wait2check = []
	layerID = 0
	## gen first layer's rule
	cur_layer_name = first_layer_name

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
		keyField_replaceOffset = []
		if layer_info[cur_idx]['keyField']:
			for i in range(len(layer_info[cur_idx]['keyField']['offset'])):
				keyField_offset +=(list(range(int(layer_info[cur_idx]['keyField']['offset'][i]),
					int(layer_info[cur_idx]['keyField']['offset'][i]+layer_info[cur_idx]['keyField']['len'][i]),2)))
			for i in range(len(layer_info[cur_idx]['keyField']['replace_offset'])):
				keyField_replaceOffset +=(list(range(int(layer_info[cur_idx]['keyField']['replace_offset'][i]),
					int(layer_info[cur_idx]['keyField']['replace_offset'][i]+layer_info[cur_idx]['keyField']['len'][i]),2)))
		dbg_print(keyField_offset)
		temp_rule_info.update({"keyField_offset":keyField_offset})
		temp_rule_info.update({"keyField_replaceOffset":keyField_replaceOffset})

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

def write_conf_rule(rule_info, file, mode):
	cntRule = 0
	preLayerID = 0
	for each_layer in rule_info:
		# layer_0
		file.write('  initial begin\n')
		if each_layer['layerID'] == 0:
			# type offset
			file.write('    //* layer_0 \n')
			file.write('    // type offset \n')
			j =0
			for type_offset in each_layer['type_offset']:
				file.write('    force '+ mode +'_top.layer_info_0.type_offset[%d]  = %d;\n' % 
					(j, type_offset))
				j += 1
			for i in range(j,2):
				file.write('    force '+ mode +'_top.layer_info_0.type_offset[%d]  = 0;\n' % i)
			# valid of key offset
			file.write('    // valid of key offset\n') 
			file.write('    force '+ mode +'_top.layer_info_0.key_offset_v = 8\'h%s;\n' % 
				str("{0:x}".format(0xff >> (8-len(each_layer['keyField_offset'])))))
			# valid of replace offset
			file.write('    // valid of replace offset\n') 
			bm_replace_offset_v = 0
			for replace_offset in each_layer['keyField_offset']:
				bm_replace_offset_v += 1<< int(replace_offset/2)
			file.write('    force '+ mode +'_top.layer_info_0.key_replaceOffset_v = 32\'h%s;\n' % 
				str("{0:x}".format(bm_replace_offset_v)))
			# key offset & replace offset
			file.write('    // key offset \n')
			j = 0
			for key_offset in each_layer['keyField_offset']:
				file.write('    force '+ mode +'_top.layer_info_0.key_offset[%d]   = %d;\n' % 
					(j, int(key_offset/2)))	
				if mode == 'deparser':
					file.write('    force '+ mode +'_top.layer_info_0.key_replaceOffset[%d]   = %d;\n' % 
						(j, int(each_layer['keyField_replaceOffset'][j]/2)))
				j += 1
			# head len
			file.write('    // head len \n')
			file.write('    force '+ mode +'_top.layer_info_0.headShift   = %d;\n' % 
				int(each_layer['head_len']/2))
			# meta len
			file.write('    // meta len \n')
			file.write('    force '+ mode +'_top.layer_info_0.metaShift   = %d;\n' % 
				int(int(each_layer['meta_len'])/2))
		
		else:
			if preLayerID == each_layer['layerID']:
				cntRule += 1
			else:
				cntRule = 0
				preLayerID = each_layer['layerID']
			file.write('    //* layer_%d \n' % preLayerID)
			# type value & mask
			file.write('    // type value & mask \n')
			j =0
			for typeValue in each_layer['typeValue']:
				file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_typeData[%d]  = %d;\n' % 
					(preLayerID, cntRule, j, typeValue))
				file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_typeMask[%d]  = %d;\n' % 
					(preLayerID, cntRule, j, each_layer['typeMask'][j]))
				j += 1
			for i in range(j,2):
				file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_typeData[%d]  = 0;\n' % 
					(preLayerID, cntRule, i))
				file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_typeMask[%d]  = 0;\n' % 
					(preLayerID, cntRule, i))

			# type offset
			file.write('    // type offset \n')
			j =0
			for type_offset in each_layer['type_offset']:
				file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_typeOffset[%d]  = %d;\n' % 
					(preLayerID, cntRule, j, type_offset))
				j += 1
			for i in range(j,2):
				file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_typeOffset[%d]  = 0;\n' % 
					(preLayerID, cntRule, i))

			# valid of key offset
			file.write('    // valid of key offset\n') 
			file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_keyOffset_v = 8\'h%s;\n' % 
				(preLayerID, cntRule, str("{0:x}".format(0xff >> (8-len(each_layer['keyField_offset']))))))
			# key offset & replace offset
			file.write('    // key offset & replace offset\n')
			j = 0
			for key_offset in each_layer['keyField_offset']:
				file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_keyOffset[%d]   = %d;\n' % 
					(preLayerID, cntRule, j, int(key_offset/2)))
				file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_keyReplaceOffset[%d]   = %d;\n' % 
					(preLayerID, cntRule, j, int(each_layer['keyField_replaceOffset'][j]/2)))
				j += 1
			# head len
			file.write('    // head len \n')
			file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_headShift = %d;\n' % 
				(preLayerID, cntRule, int(each_layer['head_len']/2)))
			# meta len
			file.write('    // meta len \n')
			file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_metaShift = %d;\n' % 
				(preLayerID, cntRule, int(int(each_layer['meta_len'])/2)))
			# rule valid
			file.write('    // meta len \n')
			file.write('    force '+ mode +'_top.'+ mode +'_layer%d.lookup_type.r_type_rule[%d].typeRule_valid = 1;\n' % 
				(preLayerID, cntRule))
		file.write('  end\n')

def gen_testbench_w_rule(rule_info, mode):
	tag_to_write = 1
	file_w = open('../src/bench_rtl/testbench_'+ mode +'_example.sv', 'w') 
	with open('../src/bench_rtl/testbench_'+ mode + '.sv', 'r') as file: 
		lines = file.readlines() 
		for line in lines:
			if line == '`ifdef READ_CONF\n':
				file_w.write(line)
				write_conf_rule(rule_info, file_w, mode)
				tag_to_write = 0
			elif line == '`endif\n':
				tag_to_write = 1
			if tag_to_write == 1:
				file_w.write(line)

# for each_layer in rule_info:
# 		# layer_0
# 		if each_layer['layerID'] == 0:
# 			# type offset
# 			file.write('//* layer_0 \n')
# 			file.write('// type offset \n')
# 			if len(each_layer['type_offset']) == 0:
# 				file.write('00_00 \n')
# 			elif len(each_layer['type_offset']) == 1:
# 				file.write(str("{0:02x}".format(each_layer['type_offset'][0])))
# 				file.write('_00 \n')
# 			else:
# 				file.write(str("{0:02x}".format(each_layer['type_offset'][0])))
# 				file.write('_' + str("{0:02x}".format(each_layer['type_offset'][1]))+'\n')
# 			# valid of key offset
# 			file.write('// valid of key offset \n')
# 			key_valid = 0xff & (0xff << (8-len(each_layer['keyField_offset'])))
# 			file.write(str("{0:02x}".format(key_valid)) + '\n')
# 			# key offset
# 			file.write('// key offset \n')
# 			j = 0
# 			for key_offset in each_layer['keyField_offset']:
# 				if j != 0:
# 					file.write('_')
# 				file.write(str("{0:02x}".format(int(each_layer['keyField_offset'][j]/2))))
# 				j += 1
# 			for i in range(j,8):
# 				if i != 0:
# 					file.write('_')
# 				file.write('00')
# 			file.write('\n')
# 			# head len
# 			file.write('// head len \n')
# 			file.write(str("{0:02x}".format(int(each_layer['head_len']/2)))+'\n')
# 			# meta len
# 			file.write('// meta len \n')
# 			file.write(str("{0:02x}".format(int(int(each_layer['meta_len'])/2)))+'\n')
		
# 		else:
# 			if preLayerID == each_layer['layerID']:
# 				cntLayer += 1
# 			else:
# 				cntLayer = 0
# 				preLayerID = each_layer['layerID']
# 			# type offset
# 			file.write('//* layer_ID & rule ID\n') 
# 			file.write(str("{0:02x}".format(each_layer['layerID'])))
# 			file.write('_' + str("{0:02x}".format(cntLayer)) +'\n')

# 			file.write('// type value & type mask\n')
# 			if len(each_layer['typeValue']) == 0:
# 				file.write('00_00 \n')
# 				file.write('00_00 \n')
# 			elif len(each_layer['typeValue']) == 1:
# 				file.write(str("{0:02x}".format(each_layer['typeValue'][0])))
# 				file.write('_00 \n')
# 				file.write(str("{0:02x}".format(each_layer['typeMask'][0])))
# 				file.write('_00 \n')
# 			else:
# 				file.write(str("{0:02x}".format(each_layer['typeValue'][0])))
# 				file.write('_' + str("{0:02x}".format(each_layer['typeValue'][1]))+'\n')
# 				file.write(str("{0:02x}".format(each_layer['typeMask'][0])))
# 				file.write('_' + str("{0:02x}".format(each_layer['typeMask'][1]))+'\n')

# 			file.write('// type offset \n')
# 			if len(each_layer['type_offset']) == 0:
# 				file.write('00_00 \n')
# 			elif len(each_layer['type_offset']) == 1:
# 				file.write(str("{0:02x}".format(each_layer['type_offset'][0])))
# 				file.write('_00 \n')
# 			else:
# 				file.write(str("{0:02x}".format(each_layer['type_offset'][0])))
# 				file.write('_' + str("{0:02x}".format(each_layer['type_offset'][1]))+'\n')
# 			# valid of key offset
# 			file.write('// valid of key offset \n')
# 			key_valid = 0xff & (0xff << (8-len(each_layer['keyField_offset'])))
# 			file.write(str("{0:02x}".format(key_valid)) + '\n')
# 			# key offset
# 			file.write('// key offset \n')
# 			j = 0
# 			for key_offset in each_layer['keyField_offset']:
# 				if j != 0:
# 					file.write('_')
# 				file.write(str("{0:02x}".format(int(each_layer['keyField_offset'][j]/2))))
# 				j += 1
# 			for i in range(j,8):
# 				if i != 0:
# 					file.write('_')
# 				file.write('00')
# 			file.write('\n')
# 			# head len
# 			file.write('// head len \n')
# 			file.write(str("{0:02x}".format(int(int(each_layer['head_len'])/2)))+'\n')
# 			# meta len
# 			file.write('// meta len \n')
# 			file.write(str("{0:02x}".format(int(int(each_layer['meta_len'])/2)))+'\n')