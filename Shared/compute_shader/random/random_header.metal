//
//  random_header.metal
//  fractal-raytracing
//
//  Created by yumeng on 2021/8/19.
//

#include <metal_stdlib>
using namespace metal;

/*

 * Random Number Generator

 * Copyright (c

 *

 *      Function                        Result

 *      ------------------------------------------------------------------

 *

 *      TausStep                        Combined Tausworthe Generator or

 *                                      Linear Feedback Shift Register (LFSR)

 *                                      random number generator. This is a

 *                                      helper method for rng, which uses

 *                                      a hybrid approach combining LFSR with

 *                                      a Linear Congruential Generator (LCG)

 *                                      in order to produce random numbers with

 *                                      periods of well over 2^121

 *

 *      rand                            A pseudo-random number based on the

 *                                      method outlined in "Efficient

 *                                      pseudo-random number generation

 *                                      for monte-carlo simulations using

 *                                      graphic processors" by Siddhant

 *                                      Mohanty et al 2012.

 *

 */
