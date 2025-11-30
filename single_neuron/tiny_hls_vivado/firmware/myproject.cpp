#include <iostream>

#include "myproject.h"
#include "parameters.h"


void myproject(
    input_t dense_input[2],
    result_t layer4_out[1]
) {

    // hls-fpga-machine-learning insert IO
    #pragma HLS ARRAY_RESHAPE variable=dense_input complete dim=0
    #pragma HLS ARRAY_PARTITION variable=layer4_out complete dim=0
    #pragma HLS INTERFACE ap_vld port=dense_input,layer4_out 
    #pragma HLS PIPELINE

    // hls-fpga-machine-learning insert load weights
#ifndef __SYNTHESIS__
    static bool loaded_weights = false;
    if (!loaded_weights) {
        nnet::load_weights_from_txt<model_default_t, 2>(w2, "w2.txt");
        nnet::load_weights_from_txt<model_default_t, 1>(b2, "b2.txt");
        loaded_weights = true;    }
#endif
    // ****************************************
    // NETWORK INSTANTIATION
    // ****************************************

    // hls-fpga-machine-learning insert layers

    layer2_t layer2_out[1];
    #pragma HLS ARRAY_PARTITION variable=layer2_out complete dim=0

    nnet::dense<input_t, layer2_t, config2>(dense_input, layer2_out, w2, b2); // dense

    nnet::relu<layer2_t, result_t, relu_config4>(layer2_out, layer4_out); // relu

}

