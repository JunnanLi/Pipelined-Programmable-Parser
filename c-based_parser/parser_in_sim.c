#include <stddef.h>
#include <stdio.h>
#include <svdpi.h>

void sim_to_read_head(int layerID,  int tag_start, int slice_id, const svOpenArrayHandle data[]){
  printf("layer ID is %d\n", layerID);
  unsigned char p1;
    for (int i = 0; i < 64; i++) {
        p1 = *(unsigned char *)svGetArrElemPtr1(data, i);
        printf("data[%d]=%02x ", i, p1);
    }
  // for(int i=0; i<8; i=i+1)
  //   printf("%d ",data[i]);
  printf("\n");
}
