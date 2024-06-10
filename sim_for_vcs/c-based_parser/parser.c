#include "parser.h"

struct parse_rule parse_rules[NUM_LAYER][NUM_RULE];

void parser_layer(uint32_t *type_offset, uint32_t *key_offset, uint32_t *head_shift, uint32_t *meta_shift,
  uint16_t **pHead, uint16_t *meta, uint32_t layerID)
{
  uint16_t *head = *pHead;
  //* extract type & key fields;
  uint8_t type_data[NUM_TYPE];
  uint16_t keyField_data[NUM_KEY];
  for(int i=0; i<NUM_TYPE; i++)
    type_data[i] = (uint8_t) head[type_offset[i]];
  for(int i=0; i<NUM_KEY; i++)
    keyField_data[i]  = head[key_offset[i]];

  //* shift;
  *pHead = &head[*head_shift];
  __DBUG_PRINT("pHead: %p\n",pHead);
  for(int i=0; i<NUM_KEY; i++){
    meta[*meta_shift+i] = keyField_data[i];
    __DBUG_PRINT("%04x_",keyField_data[i]);
  }
  __DBUG_PRINT("\t keyField_data\n");

  //* lookup;
  struct parse_rule *layer_rule = parse_rules[layerID];
  for(int i=0; i<NUM_RULE; i++){
    int hit = layer_rule[i].valid;
    for(int j=0; j<NUM_TYPE; j++)
      if(layer_rule[i].type_data[j] != layer_rule[i].type_mask[j]&type_data[j])
        hit = 0;
    if(hit == 1){
      type_offset = layer_rule[i].type_offset;
      key_offset  = layer_rule[i].key_offset;
      *head_shift = layer_rule[i].head_shift;
      *meta_shift = layer_rule[i].meta_shift + *meta_shift;
    }
  }
}

int main(){
  //* initial rules
  parse_rules[0][0].type_data[0] = 0x08;
  parse_rules[0][0].type_data[1] = 0x00;
  parse_rules[0][0].type_mask[0] = 0xff;
  parse_rules[0][0].type_mask[1] = 0xff;
  parse_rules[0][0].valid = 1;
  for(int i=0; i<NUM_TYPE; i++)
    parse_rules[0][0].type_offset[i] = i;
  for(int i=0; i<NUM_KEY; i++)
    parse_rules[0][0].key_offset[i] = i;
  parse_rules[0][0].head_shift = 14;
  parse_rules[0][0].meta_shift = 12;

  for(int i=1; i<NUM_RULE; i++)
    parse_rules[0][i].valid = 0;

  //* initial head & meta;
  uint16_t head[100];
  uint16_t meta[20] = {0};
  uint16_t *pHead = head;
  uint16_t *pMeta = meta;
  for(int i=0; i<100; i++)
    head[i] = i | i<<8;
  head[6] = 0x0800;

  //* initial type & key offset;
  uint32_t type_offset[NUM_TYPE];
  uint32_t key_offset[NUM_KEY];
  type_offset[0] = 12;
  type_offset[1] = 13;
  uint32_t head_shift = 7;
  uint32_t meta_shift = 2;
  for(int i=0; i<NUM_KEY; i++)
    key_offset[i] = i;
  
  __DBUG_PRINT("head: %p\n",pHead);
  parser_layer(type_offset, key_offset, &head_shift, &meta_shift, (uint16_t **) &pHead, pMeta, 0);
  __DBUG_PRINT("head: %p\n",pHead);
  __DBUG_PRINT("head[0]: %04x\n",pHead[0]);
  
  //* echo result
  for(int i=0; i<100-7; i++){
    printf("%04x_",pHead[i]);
    if(i%8 == 7)
      printf("\n");
  }
  printf("\t head\n");
  for(int i=0; i<20; i++){
    printf("%04x_",pMeta[i]);
    if(i%8 == 7)
      printf("\n");
  }
  printf("\t meta\n");
  return 0;
};