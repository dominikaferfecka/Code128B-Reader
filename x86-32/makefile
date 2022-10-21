
all: asm cc link
cc:
	cc -m32 -std=c99 -c image.c

asm:
	nasm -f elf32 -g projekt.asm

link:
	cc -m32 -o image image.o projekt.o