// cc -O2 block.c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define BLOCK_SIZE 64
#define B BLOCK_SIZE / sizeof(double)

static __attribute__((noinline))
void transpose(double input[256][256], volatile double output[256][256]) {
    for (int i = 0; i < 256; i++)
        for (int j = 0; j < 256; j++)
            output[j][i] = input[i][j];
}

static __attribute__ ((noinline))
void block_transpose(double input[256][256], volatile double output[256][256]) {
    for (int i = 0; i < 256; i += B)
        for (int j = 0; j < 256; j += B) {
            int next = j + B < 256 ? j + B : j;
            __builtin_prefetch(&input[i][next], 0, 0);
            __builtin_prefetch((double *)&output[next][i], 1, 0); // probably UB!
            for (int k = 0; k < B; k++)
                for (int l = 0; l < B; l++)
                    output[j + l][i + k] = input[i + k][j + l];
        }

}

static void init_doubles(double input[256][256]) {
    for (int i = 0; i < 256; i++)
        for (int j = 0; j < 256; j++)
            input[i][j] = (double)rand();
}

int main(int argc, char **argv) {
    srand(time(NULL));
    double input[256][256] __attribute__((aligned(BLOCK_SIZE)));
    init_doubles(input);
    struct timespec start, end;
    volatile double output[256][256] __attribute__((aligned(BLOCK_SIZE)));
    if (argc > 1 && strcmp(argv[1], "1") == 0) {
        clock_gettime(CLOCK_REALTIME, &start);
        block_transpose(input, output);
    } else {
        clock_gettime(CLOCK_REALTIME, &start);
        transpose(input, output);
    }
    clock_gettime(CLOCK_REALTIME, &end);
    printf("%ld\n", end.tv_nsec - start.tv_nsec);
    return 0;
}
