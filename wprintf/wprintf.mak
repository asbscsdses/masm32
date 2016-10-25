# my first makefile
EXE = wprintf.exe
OBJS = wprintf.obj
#RES = x.res	

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(EXE) : $(OBJS) $(RES)
	Link $(LINK_FLAG) /out:$(EXE) $(OBJS) 
#$(RES)
#$(OBJS) : Common.inc
#y.obj : y.inc

.asm.obj:
		ml $(ML_FLAG) $<
#.rc.res:
#		rc $<
		
clean: 
	del *.obj
	del *.exe