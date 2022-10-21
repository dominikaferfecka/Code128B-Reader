
all: asm cc link
cc:
	cc -m64 -std=c99 -c image.c

asm:
	nasm -f elf64 -g projekt.asm

link:
	cc -m64 -o image image.o projekt.o