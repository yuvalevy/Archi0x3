 

ass3: clean printer.o coroutines.o scheduler.o ass3.o
	ld -melf_i386 -g -o ass3 ass3.o printer.o coroutines.o scheduler.o

ass3.o: ass3.s
	nasm -g -f elf -w+all -o ass3.o ass3.s


scheduler.o: scheduler.s
	nasm -g -f elf -w+all -o scheduler.o scheduler.s

coroutines.o: coroutines.s
	nasm -g -f elf -w+all -o coroutines.o coroutines.s

printer.o: printer.s
	nasm -g -f elf -w+all -o printer.o printer.s

clean:
	rm -f *.o ass3

