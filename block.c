#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define B 128 / 16

static void transpose(double input[256][256], volatile double output[256][256]) {
    for (int i = 0; i < 256; i++)
        for (int j = 0; j < 256; j++)
            output[j][i] = input[i][j];
    
}

static void block_transpose(double input[256][256], volatile double output[256][256]) {
    for (int i = 0; i < 256; i += B)
        for (int j = 0; j < 256; j += B)
            for (int k = 0; k < B; k++)
                for (int l = 0; l < B; l++)
                    output[j + l][i + k] = input[i + k][j + l];
                    
}

static void init_doubles(double input[256][256]) {
    for (int i = 0; i < 256; i++)
        for (int j = 0; j < 256; j++)
            input[i][j] = (double)rand();
}

int main(int argc, char **argv) {
    srand(time(NULL));
    double input[256][256];
    init_doubles(input);
    struct timespec start, end;
    clock_gettime(CLOCK_REALTIME, &start);
    volatile double output[256][256];
    if (argc > 1 && strcmp(argv[1], "1") == 0)
        block_transpose(input, output);
    else
        transpose(input, output);
    clock_gettime(CLOCK_REALTIME, &end);
    printf("%ld\n", end.tv_nsec - start.tv_nsec);
    return 0;
}
