#include <stdio.h> 
#include <pcap.h> 
#include <arpa/inet.h> 
#include <time.h> 
#include <stdlib.h> 
#include <string.h> 
#include <unistd.h>
#include <libnet.h>
#include <pthread.h>

#define BUFSIZE 1514

#ifndef SEND_RECV_H__
#define SEND_RECV_H__

typedef unsigned short u16;
typedef unsigned char u8;
typedef unsigned int u32;

#define NET_INTERFACE "eno1"
// #define NET_INTERFACE "enx00e04d6da7b3"


#if(DP4C==1)
	struct one_128b{
		u16 conf_type[2];	//* 01 is write sel, 02 is read sel;
							//* 03 is write proc,04 is read proc;
							//* 
		u32 pad;
		u32 tcm_data;
		u32 addr;
	};

	struct context{
		struct one_128b one128b[100];
	};

	struct send_ctx{
		u16 type;
		int lens;
		struct context payload;
	};

#else 
	struct context{
		u16 conf_type;	//* 01 is write sel, 02 is read sel;
						//* 03 is write proc,04 is read proc;
						//* 
		u16 tcm_addr;
		u32 check_sum;
		u32 pad[2];
		u32 tcm_data[400];	
	};

	struct send_ctx{
		u16 type;
		int lens;
		struct context payload;
	};
#endif

#if(DP4C==1)
	void read_tcm(int lineNum);
	void open_backPressure(int value);
#endif
	void set_read_sel(int read, u32 value);
	void write_tcm(char *fileName, int lineNum);
	void send_packet(struct send_ctx *sendCtx);
	void recv_packet(int num, char *bpf_recv_s);
	void recv_print_value();

#endif
