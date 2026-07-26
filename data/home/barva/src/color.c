#include "color.h"
#include <stdio.h>

/*
 * Returns a "mean" of two colors based on *value*.
 * *value* should be in [0; 1] where smaller values result in a color that is
 * closer to *c1* and vice versa.
 */
struct color color_mean(struct color c1, struct color c2, float value) {
    //printf("c1 = %02X %02X %02X %02X\n", c1.rgba[0], c1.rgba[1], c1.rgba[2], c1.rgba[3]);
    //printf("c2 = %02X %02X %02X %02X\n", c2.rgba[0], c2.rgba[1], c2.rgba[2], c2.rgba[3]);
    if (value > 1.0) value = 1.0;
    for (int i = 0; i < 4; ++i) {
        c1.rgba[i] += (c2.rgba[i] - c1.rgba[i]) * value;
    }
    //printf("value = %f\n", value);
    //printf("out = %02X %02X %02X %02X\n", c1.rgba[0], c1.rgba[1], c1.rgba[2], c1.rgba[3]);
    return c1;
}
