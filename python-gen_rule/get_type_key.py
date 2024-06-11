# get type info
global DBG_PRINT
DBG_PRINT = 0
OFFSET = 1
LEN = 2
MASK = 4
REPLACE_OFFSET = 4
VALUE1 = 5
NEXT_HEADER1 = 6
VALUE2 = 7
NEXT_HEADER2 = 8
VALUE3 = 9
NEXT_HEADER3 = 10

def dbg_print(*args, **kwargs):
	if DBG_PRINT:
		print(*args, **kwargs)

def get_type_info(data, list_index_notnull, idx):
	temp_data = data.iloc[list_index_notnull[idx]+1:list_index_notnull[idx+1]]
	list_type = temp_data[['field','offset','len','type','mask','value1','next_header1','value2','next_header2','value3','next_header3']].dropna(axis=0, how='any').values.tolist()
	dbg_print(list_type)
	temp_type_info = {}
	if len(list_type) == 0:
		return temp_type_info
	temp_type_info.update({"offset":list_type[0][OFFSET]})
	temp_type_info.update({"len":list_type[0][LEN]})
	temp_type_info.update({"mask":list_type[0][MASK]})
	temp_list_proto = []
	for i in range(3):
		if list_type[0][VALUE1+2*i] != '/':
			temp_list_proto.append([list_type[0][VALUE1+2*i],list_type[0][NEXT_HEADER1+2*i]])
			temp_type_info.update({"proto":temp_list_proto})
	dbg_print(temp_type_info)
	return temp_type_info

def get_key_info(data, list_index_notnull, idx):
	temp_data = data.iloc[list_index_notnull[idx]+1:list_index_notnull[idx+1]]
	list_keyField = temp_data[['field','offset','len','key','meta_offset']].dropna(axis=0, how='any').values.tolist()
	temp_key_info = {}
	if len(list_keyField) == 0:
		return temp_key_info
	list_offset = []
	list_len = []
	list_replace_offset = []
	for i in range(len(list_keyField)):
		list_offset.append(list_keyField[i][OFFSET])
		list_len.append(list_keyField[i][LEN])
		list_replace_offset.append(list_keyField[i][REPLACE_OFFSET])
	temp_key_info.update({"offset":list_offset})
	temp_key_info.update({"len":list_len})
	temp_key_info.update({"replace_offset":list_replace_offset})
	dbg_print(temp_key_info)
	return temp_key_info
