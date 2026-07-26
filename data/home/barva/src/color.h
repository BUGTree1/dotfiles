#ifndef COLOR_H
#define COLOR_H

struct color {
    int rgba[4];
};
struct color color_mean(struct color c1, struct color c2, float value);

#endif
