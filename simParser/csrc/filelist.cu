PIC_LD=ld

ARCHIVE_OBJS=
ARCHIVE_OBJS += _28389_archive_1.so
_28389_archive_1.so : archive.0/_28389_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../simv_1.daidir//_28389_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../simv_1.daidir//_28389_archive_1.so $@


ARCHIVE_OBJS += _28416_archive_1.so
_28416_archive_1.so : archive.0/_28416_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../simv_1.daidir//_28416_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../simv_1.daidir//_28416_archive_1.so $@


ARCHIVE_OBJS += _28417_archive_1.so
_28417_archive_1.so : archive.0/_28417_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../simv_1.daidir//_28417_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../simv_1.daidir//_28417_archive_1.so $@


ARCHIVE_OBJS += _28418_archive_1.so
_28418_archive_1.so : archive.0/_28418_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -Bsymbolic  -o .//../simv_1.daidir//_28418_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../simv_1.daidir//_28418_archive_1.so $@





O0_OBJS =

$(O0_OBJS) : %.o: %.c
	$(CC_CG) $(CFLAGS_O0) -c -o $@ $<
 

%.o: %.c
	$(CC_CG) $(CFLAGS_CG) -c -o $@ $<
CU_UDP_OBJS = \


CU_LVL_OBJS = \
SIM_l.o 

MAIN_OBJS = \
objs/amcQw_d.o 

CU_OBJS = $(MAIN_OBJS) $(ARCHIVE_OBJS) $(CU_UDP_OBJS) $(CU_LVL_OBJS)

