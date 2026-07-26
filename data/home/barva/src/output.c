#include "output.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

void set_bg(float value, struct color bg, struct color target, enum output_format fmt) {
    switch (fmt) {
    case TTY:
        bg = color_mean(bg, target, value);
        //printf("[%d]#%02X%02X%02X\n", (int)(((float)bg.rgba[3] / 255) * 100), bg.rgba[0], bg.rgba[1], bg.rgba[2]);
        printf("\033]11;[%d]#%02X%02X%02X\007", (int)(((float)bg.rgba[3] / 255) * 100), bg.rgba[0], bg.rgba[1], bg.rgba[2]);
        //printf("rgba:%02X/%02X/%02X/%02X\n", bg.rgba[0], bg.rgba[1], bg.rgba[2], bg.rgba[3]);
        //printf("\033]11;rgba:%02X/%02X/%02X/%02X\007", bg.rgba[0], bg.rgba[1], bg.rgba[2], bg.rgba[3]);
        fflush(stdout);
        break;
    case HEX:
        bg = color_mean(bg, target, value);
        printf("#%02X%02X%02X%02X\n", bg.rgba[0], bg.rgba[1], bg.rgba[2], bg.rgba[3]);
        fflush(stdout);
        break;
    case BYT:
        putchar(value * 255);
        fflush(stdout);
        break;
    }
}
