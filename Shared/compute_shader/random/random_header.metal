//
//  random_header.metal
//  fractal-raytracing
//
//  Created by yumeng on 2021/8/19.
//

#include <metal_stdlib>
using namespace metal;

#pragma once
// 参照 https://www.pcg-random.org/ 实现

typedef struct { uint64_t state;  uint64_t inc; } pcg32_random_t;

uint32_t pcg32_random_r(thread pcg32_random_t* rng)
{
    uint64_t oldstate = rng->state;
    rng->state = oldstate * 6364136223846793005ULL + rng->inc;
    uint32_t xorshifted = ((oldstate >> 18u) ^ oldstate) >> 27u;
    uint32_t rot = oldstate >> 59u;
    return (xorshifted >> rot) | (xorshifted << ((-rot) & 31));
}

void pcg32_srandom_r(thread pcg32_random_t* rng, uint64_t initstate, uint64_t initseq)
{
    rng->state = 0U;
    rng->inc = (initseq << 1u) | 1u;
    pcg32_random_r(rng);
    rng->state += initstate;
    pcg32_random_r(rng);
}

// 生成0～1之间的浮点数
float randomF(thread pcg32_random_t* rng)
{
    //return pcg32_random_r(rng)/float(UINT_MAX);
    return ldexp(float(pcg32_random_r(rng)), -32);
}

// 生成x_min ~ x_max之间的浮点数
float randomRange(thread pcg32_random_t* rng, float x_min, float x_max){
    return randomF(rng) * (x_max - x_min) + x_min;
}

// Generate a random float in the range [0.0f, 1.0f] using x, y, and z (based on the xor128 algorithm)
float rand_test(int x, int y, int z)
{
    int seed = x + y * 57 + z * 241;
    seed= (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

struct TRng {
    float x;
    float y;
    
    TRng(float x, float y)
    {
        this->x = x;
        this->y = y;
    }
    
    float rand(){
        float2 xy = float2(this->x, this->y);
        this->x = fract(sin(dot(xy, float2(12.9898, 78.233))) * 43758.5453);
        xy = float2(this->x, this->y);
        this->y = fract(sin(dot(xy, float2(12.9898, 78.233))) * 43758.5453);
        return this->x;
    }
};
