# Mael GRELLIER NEAU 1/03/24


# If we type make build it will execute the cabal command
build:
	cabal build

# If we type make run it will run the cabal executable with 4 cores and the array to 15000 values,
# it create the .eventlog file to use the profiler tool ThreadScope
run: 
	srun --partition=amd-longq --cpus-per-task=4 cabal exec -- haskell-totient 1 15000 +RTS -N4 -l