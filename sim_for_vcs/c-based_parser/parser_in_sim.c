#include <stddef.h>
#include <stdio.h>
#include <svdpi.h>

#define NUM_LAYER 4
#define NUM_RULE 8
#define NUM_TYPE 2
#define NUM_KEY 8

#define DBUG_PRINT

#ifdef DBUG_PRINT
    #define __DBUG_PRINT(fmt, ...) printf(fmt, ##__VA_ARGS__)
#else
    #define __DBUG_PRINT(fmt, ...)
#endif

struct parse_rule{
  uint32_t valid;
  uint8_t  type_data[NUM_TYPE];
  uint8_t  type_mask[NUM_TYPE];
  uint32_t type_offset[NUM_TYPE];
  uint32_t key_offset[NUM_KEY];
  uint32_t key_offset_valid[NUM_KEY];
  uint32_t key_offset_replace[NUM_KEY];
  uint32_t head_shift;
  uint32_t meta_shift;
};
struct parse_rule parse_rules[NUM_LAYER][NUM_RULE];

unsigned char head[NUM_LAYER][4096] = {0};
unsigned char meta[NUM_LAYER][4096] = {0};
int headLen = 0;
int metaLen = 0;
int headOffset[NUM_LAYER+1] = {0};
int metaOffset[NUM_LAYER+1] = {0};
int typeOffset[NUM_LAYER][NUM_TYPE] = {0};
int keyOffset[NUM_LAYER][NUM_KEY] = {0};
int keyOffset_v[NUM_LAYER][NUM_KEY] = {0};


void check_head_meta(int cur_layerID){
  if(cur_layerID == 1){
    for(int i=0; i<NUM_TYPE; i++){
      typeOffset[0][i] = parse_rules[0][0].type_offset[i] + headOffset[0]*2;
    }
    for(int i=0; i<NUM_KEY; i++){
      keyOffset[0][i] = parse_rules[0][0].key_offset[i] + headOffset[0]*2;
      keyOffset_v[0][i] = parse_rules[0][0].key_offset_valid[i];
    }
    headOffset[1] = parse_rules[0][0].head_shift*2;
    metaOffset[1] = parse_rules[0][0].meta_shift*2;
  }
  
  uint8_t type_data[NUM_TYPE];
  uint8_t key_data[NUM_KEY*2];
  for(int i=0; i<NUM_TYPE; i++){
    int temp_offset = headOffset[cur_layerID-1] + typeOffset[cur_layerID-1][i];
    type_data[i] = head[0][temp_offset];
  }
  for(int i=0; i<NUM_KEY; i++){
    int temp_offset = headOffset[cur_layerID-1] + keyOffset[cur_layerID-1][i]*2;
    key_data[2*i] = head[0][temp_offset];
    key_data[2*i+1] = head[0][temp_offset+1];
    // printf("\rlayID:%d,%d\n",cur_layerID,temp_offset);
  }
    // printf("headOffset:%d\n",headOffset[cur_layerID-1]);


  //* check meta
  for(int i=0; keyOffset_v[cur_layerID][i]==1; i++){
    if(meta[cur_layerID][metaOffset[cur_layerID-1]+2*i] != key_data[2*i]){
      printf("\rError: meet mismatch in layerID:%d\n",cur_layerID);
      printf("meta[%d]:%02x,key_field[%d]:%02x\n",metaOffset[cur_layerID-1]+2*i,meta[cur_layerID][metaOffset[cur_layerID-1]+2*i],i,key_data[2*i]);
      exit(0);
    }
    if(meta[cur_layerID][metaOffset[cur_layerID-1]+2*i+1] != key_data[2*i+1]){
      printf("\rError: meet mismatch in layerID:%d\n",cur_layerID);
      printf("meta[%d]:%02x,key_field[%d]:%02x\n",metaOffset[cur_layerID-1]+2*i+1,meta[cur_layerID][metaOffset[cur_layerID-1]+2*i+1],i,key_data[2*i+1]);
      exit(0);
    }
  }

  //* lookup;
  struct parse_rule *layer_rule = parse_rules[cur_layerID];
  for(int i=0; i<NUM_RULE; i++){
    int hit = layer_rule[i].valid;
    // if(hit){
    //   printf("type_data:%02x%02x\n",layer_rule[i].type_data[0],layer_rule[i].type_data[1]);
    //   printf("type_mask:%02x%02x\n",layer_rule[i].type_mask[0],layer_rule[i].type_mask[1]);
    //   printf("type:%02x%02x\n",type_data[0],type_data[1]);
    // }
    for(int j=0; j<NUM_TYPE; j++){
      // printf("type_mask&type:%02x\n",layer_rule[i].type_mask[j]&type_data[j]);
      if(layer_rule[i].type_data[j] != (layer_rule[i].type_mask[j]&type_data[j]))
        hit = 0;
      // printf("hit:%d\n",hit);
    }
    if(hit == 1){
      __DBUG_PRINT("\rhit layerID:%d, ruleID:%d\n",cur_layerID,i);
      headOffset[cur_layerID+1] = headOffset[cur_layerID] + layer_rule[i].head_shift*2;
      metaOffset[cur_layerID+1] = metaOffset[cur_layerID] + layer_rule[i].meta_shift*2;
      for(int j=0; j<NUM_TYPE; j++)
        typeOffset[cur_layerID][j] = layer_rule[i].type_offset[j];
      for(int j=0; j<NUM_TYPE; j++){
        keyOffset[cur_layerID][j]  = layer_rule[i].key_offset[j];
        keyOffset_v[cur_layerID][j]  = layer_rule[i].key_offset_valid[j];
      }
    }
  }
}


void sim_to_read_head(int layerID, int tag_start, int slice_id, const svOpenArrayHandle data_head[]){
  printf("\rlayer ID is %d\n", layerID);  
  int base_offset = 0;
  if(tag_start != 1)
    base_offset = slice_id*64;
  for (int i = 0; i < 64; i++) {
      head[layerID][base_offset+i] = *(unsigned char *)svGetArrElemPtr1(data_head, i);
  }
  if(layerID == 0)
    headLen = base_offset + 64;
  printf("head: ");
  for(int i=0; i<headLen; i++){
    printf("%02x_",head[layerID][i]);
    if(i%16 == 15)
      printf("\n      ");
  }
}

void sim_to_read_meta(int layerID, int tag_start, int tag_end, int slice_id, const svOpenArrayHandle data_meta[]){
  int base_offset = 0;
  if(tag_start != 1)
    base_offset = slice_id*64;
  for (int i = 0; i < 64; i++) {
      meta[layerID][base_offset+i] = *(unsigned char *)svGetArrElemPtr1(data_meta, i);
  }
  if(layerID == 0)
    metaLen = base_offset + 64;
  printf("\rmeta: ");
  for(int i=0; i<metaLen; i++){
    printf("%02x_",meta[layerID][i]);
    if(i%16 == 15)
      printf("\n      ");
  }
  if(tag_end){
    check_head_meta(layerID);
  }
}

void sim_to_read_rule(int layerID, int ruleID, int ruleValid,
  const svOpenArrayHandle typeData, const svOpenArrayHandle typeMask, const svOpenArrayHandle typeOffset,
  const svOpenArrayHandle keyOffset_v, const svOpenArrayHandle keyOffset, const svOpenArrayHandle keyReplaceOffset,
  int headShift, int metaShift)
{
  parse_rules[layerID][ruleID].valid = ruleValid;
  for(int i=0; i<NUM_TYPE; i++){
    parse_rules[layerID][ruleID].type_data[i] = *(unsigned char *)svGetArrElemPtr1(typeData, i);
    parse_rules[layerID][ruleID].type_mask[i] = *(unsigned char *)svGetArrElemPtr1(typeMask, i);
    parse_rules[layerID][ruleID].type_offset[i] = *(unsigned char *)svGetArrElemPtr1(typeOffset, i);
  }
  for(int i=0; i<NUM_KEY; i++){
    parse_rules[layerID][ruleID].key_offset[i] = *(unsigned char *)svGetArrElemPtr1(keyOffset, i);
    parse_rules[layerID][ruleID].key_offset_valid[i] = *(unsigned char *)svGetArrElemPtr1(keyOffset_v, i);
    parse_rules[layerID][ruleID].key_offset_replace[i] = *(unsigned char *)svGetArrElemPtr1(keyReplaceOffset, i);
  }
  parse_rules[layerID][ruleID].head_shift = headShift;
  parse_rules[layerID][ruleID].meta_shift = metaShift;

  if(parse_rules[layerID][ruleID].valid){
    printf("layerID:%d,\truleID:%d\n",layerID,ruleID);
    for(int i=0; i<NUM_TYPE; i++)
      printf("    data:%02x,\tmask:%02x,\tnext_offset:%d\n",parse_rules[layerID][ruleID].type_data[i],
        parse_rules[layerID][ruleID].type_mask[i],parse_rules[layerID][ruleID].type_offset[i]);
    for(int i=0; i<NUM_KEY; i++)
      printf("    offset_v:%d,\toffset:%02x,\toffset_replace:%d\n",parse_rules[layerID][ruleID].key_offset_valid[i],
        parse_rules[layerID][ruleID].key_offset[i],parse_rules[layerID][ruleID].key_offset_replace[i]);
    printf("    head_shift:%d,\tmeta_shift:%d\n",parse_rules[layerID][ruleID].head_shift,
      parse_rules[layerID][ruleID].meta_shift);
  }
}