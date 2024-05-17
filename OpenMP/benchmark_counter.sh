# If you are collecting data for the coursework, you should run this
# script on the head node on the cluster.
# This script is done for collecting the number of operations on long values done for each configuration
# Uncomment all lines that increment this counter in TotientRange.c before executing
echo "input,nb_operations" > counter.csv

for inputSize in 15000 30000 100000
do
    echo -n $inputSize >> counter.csv
    echo -n "," >> counter.csv
    # to test on any computer (e.g. in EM 2.50 or your laptop)
    # printf "%s" "$(./totient 1 $inputSize)" >> counter.csv
    # to test on a Robotarium cluster compute node
    printf "%s" "$(srun --partition=amd-longq --cpus-per-task=64  ./totient 1 $inputSize)" >> counter.csv
    echo "" >> counter.csv
done
