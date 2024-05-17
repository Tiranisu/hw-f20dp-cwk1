CC=gcc
CORES=8

totient: TotientRange.c
	$(CC) -Wall -o totient TotientRange.c -fopenmp

# Local machine tests
test: totient
	./totient 1 15000
	./totient 1 30000
	./totient 1 100000

# Robotarium tests
run: totient
	srun --partition=amd-longq --cpus-per-task $(CORES) ./totient 1 15000
	srun --partition=amd-longq --cpus-per-task $(CORES) ./totient 1 30000
	srun --partition=amd-longq --cpus-per-task $(CORES) ./totient 1 100000

.PHONY: clean

clean:
	rm totient