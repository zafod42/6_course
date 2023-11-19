
PWD=~/Documents/programming/asm/course-treg/
TASM=~/Documents/DOS_ASM/tasm/


all: run

build: bin/COURSE.EXE

show:	
	cat bin/BUILD.LOG bin/LINK.LOG

bin/COURSE.EXE: src/course.asm src/print.asm
	mkdir -p bin
	dosbox 	-c "@echo off"\
		-c "cls"\
		-c "mount c $(TASM)"\
		-c "path=z:\\;c:\\"\
		-c "mount d $(PWD)/src/"\
		-c "mount e $(PWD)/bin/"\
		-c "e:"\
		-c "tasm d:\\course.asm > build.log"\
		-c "tlink course.obj > link.log"\
		-c "exit"

run: bin/COURSE.EXE
	dosbox 	-c "@echo off"\
		-c "mount d $(PWD)/bin"\
		-c "keyb ru441 866"\
		-c "cls"\
		-c "d:\\course.exe"\
		-c "exit"

clean:
	rm bin/*.MAP bin/*.OBJ bin/*.EXE bin/*.LOG

