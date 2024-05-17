// TotientRance.c - Sequential Euler Totient Function (C Version)
// compile: gcc -Wall -O -o TotientRange TotientRange.c
// run:     ./TotientRange lower_num uppper_num

// Greg Michaelson 14/10/2003
// Patrick Maier   29/01/2010 [enforced ANSI C compliance]

// This program calculates the sum of the totients between a lower and an 
// upper limit using C longs. It is based on earlier work by:
// Phil Trinder, Nathan Charles, Hans-Wolfgang Loidl and Colin Runciman

// ---------------------------------------------------
// ---------------- AUTHOR'S NAME---------------------

// OpenMP Parallel Implementation done by Enzo Peigné

// ---------------------------------------------------

#include <stdio.h>
#include <time.h>
#include <omp.h>

// hcf x 0 = x
// hcf x y = hcf y (rem x y)

// Counter for arithmetic operations on long values
unsigned long long counter = 0;

// Increment function (with an omp atomic to avoid collisions between threads)
// We call the function each time we had an arithmetic operation in each function
void incrementCount(){
  #pragma omp atomic
  counter++;
}

long hcf(long x, long y)
{
  long t;

  while (y != 0) {
    t = x % y;
    x = y;
    y = t;
    incrementCount();
  }
  return x;
}
// relprime x y = hcf x y == 1

int relprime(long x, long y)
{
  return hcf(x, y) == 1;
}


// euler n = length (filter (relprime n) [1 .. n-1])

long euler(long n)
{
  long length, i;

  length = 0;
  for (i = 1; i < n; i++)
    if (relprime(n, i))
      length++;
  return length;
}

long eulerPara(long n)
{
  long length, i;

  length = 0;
  // Parallelisation of euler function for N threads (where N is the number of cores)
  #pragma omp parallel
  {
    #pragma omp for reduction(+:length) //reduction parameter to avoid errors in the result due to parallelism
    for (i = 1; i < n; i++)
      if (relprime(n, i))
        length++;
        incrementCount();
  }
  return length;
}


// sumTotient lower upper = sum (map euler [lower, lower+1 .. upper])

long sumTotientSeq(long lower, long upper)
{
  long sum, i;

  sum = 0;
  for (i = lower; i <= upper; i++)
    sum = sum + euler(i);
    counter++;
  return sum;
}

long sumTotientPara(long lower, long upper)
{
  long sum, i;

  sum = 0;

  // Parallelisation of sumTotient function for N threads (where N is the number of cores)
  #pragma omp parallel
  {
    #pragma omp for reduction(+:sum) //reduction parameter to avoid errors in the result due to parallelism
    for (i = lower; i <= upper; i++)
      sum = sum + eulerPara(i);
      incrementCount();
  }
  
  return sum;
}


void runBenchmark()
{
  clock_t start, end;
  double time_taken;

  for (long i = 1; i < 1000000 ; i = i + 100000) {
    start = clock();
    euler(i);
    end = clock();
    time_taken = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("euler(%lu) = %f seconds\n", i, time_taken);
  }   
}

int main(int argc, char ** argv)
{
  long lower, upper;

  if (argc != 3) {
    printf("not 2 arguments\n");
    return 1;
  }
  sscanf(argv[1], "%ld", &lower);
  sscanf(argv[2], "%ld", &upper);

  double start, stop;
  double seqTime, paraTime;

  // printf("C: Sum of Totients  between [%ld..%ld]\n\n", lower, upper);

  // // Sequential version
  // start = omp_get_wtime();
  // printf("Result in Sequential: %ld\n", sumTotientSeq(lower, upper));
  // stop = omp_get_wtime();

  // seqTime = stop - start;

  // printf("Execution time in Sequential: %lf sec\n", seqTime);

  // printf("\n");

  // Parallel version
  start = omp_get_wtime();

  sumTotientPara(lower, upper);

  // printf("Result in Parallel: %ld\n", sumTotientPara(lower, upper));

  stop = omp_get_wtime();

  paraTime = stop - start;

  

  // printf("%lf", paraTime);

  printf("%lld\n", counter);
  
  // printf("\n");

  // printf("Speedup: %lf\n", seqTime / paraTime);
  // printf("Efficiency: %.2lf %%\n", ((seqTime / paraTime) / 8)*100);

  // printf("\n");

  return 0;
}

