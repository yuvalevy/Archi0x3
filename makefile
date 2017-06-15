

ass3: clean printer.o coroutines.o scheduler.o ass3.o cell.o
	gcc -m32 -g -o ass3 ass3.o printer.o coroutines.o scheduler.o cell.o

ass3.o: ass3.s
	nasm -g -f elf -w+all -o ass3.o ass3.s

scheduler.o: scheduler.s
	nasm -g -f elf -w+all -o scheduler.o scheduler.s

coroutines.o: coroutines.s
	nasm -g -f elf -w+all -o coroutines.o coroutines.s

printer.o: printer.s
	nasm -g -f elf -w+all -o printer.o printer.s

cell.o: cell.c
	gcc -m32 -Wall -ansi -c -o cell.o cell.c

clean:
	rm -f *.o ass3

