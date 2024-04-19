#include "parser.h"

void parser_layer(uint *type_offset, uint *key_offset, uint *head_shift, uint *meta_shift,
  uint16_t *head, uint16_t *meta, uint layerID)
{
  //* extract type & key fields;
  uint16_t data_type[NUM_TYPE];
  uint16_t data_type[NUM_KEY];
  for(int i=0; i<NUM_TYPE; i++)
    data_type[i] = head[type_offset[i]];
  for(int i=0; i<NUM_KEY; i++)
    data_key[i]  = head[key_offset[i]];

  //* lookup;
  
}
