#include <stdio.h> 
#include <pcap.h> 
#include <arpa/inet.h> 
#include <time.h> 
#include <stdlib.h> 
#include <string.h> 
#include <unistd.h>
#include <libnet.h>
#include <pthread.h>

#define DBUG_PRINT

#ifndef PARSER_H__
#define PARSER_H__

#define NUM_LAYER 3
#define NUM_RULE  8
#define NUM_TYPE  2
#define NUM_KEY   8


struct parse_rule{
	uint32_t valid;
	uint8_t  type_data[NUM_TYPE];
	uint8_t  type_mask[NUM_TYPE];
	uint32_t type_offset[NUM_TYPE];
	uint32_t key_offset[NUM_KEY];
	uint32_t head_shift;
	uint32_t meta_shift;
};

#ifdef DBUG_PRINT
    #define __DBUG_PRINT(fmt, ...) printf(fmt, ##__VA_ARGS__)
#else
    #define __DBUG_PRINT(fmt, ...)
#endif

#endif
