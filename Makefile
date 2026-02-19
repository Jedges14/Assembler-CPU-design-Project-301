# #General Purpose Makefile (Prateek Bhakta)

# EXECS = assemble
# OBJS = project1.o

# # For *nix and Mac
# CC = g++
# CCFLAGS	 = -std=c++17 

# # Will need to do something different on Windows

# all: $(EXECS)
# #comment
# assemble: $(OBJS)
# 	$(CC) $(CCFLAGS) -I . $^ -o $@

# %.o: %.cpp *.h
# 	$(CC) $(CCFLAGS) -I . -c $<

# clean:
# 	rm -f $(OBJS) $(EXECS)



#instructions to use our expanded version which handles immediates but that messes up test cases

#below will assemble the expanded version if make assemble_alt is ran and then when execute use ./assemble_alt instead

EXECS = assemble assemble_alt

CC = g++
CCFLAGS = -std=c++17

all: $(EXECS)

assemble: project1.o
	$(CC) $(CCFLAGS) -I . $^ -o $@

assemble_alt: project1expanded.o
	$(CC) $(CCFLAGS) -I . $^ -o $@

%.o: %.cpp *.h
	$(CC) $(CCFLAGS) -I . -c $<

clean:
	rm -f *.o $(EXECS)