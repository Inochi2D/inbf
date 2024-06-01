# This is a comment line
CC=clang

DC=dub

# CFLAGS will be the options passed to the compiler.
CFLAGS=-I"../../out/" -c -Wall
LFLAGS=-L"../../out/" -linbf -Wl,-rpath,"@executable_path"

OBJECTS=test.o

all: dcode test

dcode:
	cd ../..; dub build --build=release
	cp ../../out/*.dylib .

test: $(OBJECTS)
	$(CC) $(LFLAGS) $(OBJECTS) -o test

%.o: %.c
	$(CC) $(CFLAGS) $<

clean:
	rm -rf *.o *.dylib
	rm test