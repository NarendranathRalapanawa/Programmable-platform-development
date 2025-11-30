// Pull in the full myproject implementation
#include "myproject.cpp"

void nn_top(input_t x0, input_t x1, result_t &y) {
    #pragma HLS INTERFACE ap_ctrl_none port=return
    #pragma HLS INTERFACE ap_none port=x0
    #pragma HLS INTERFACE ap_none port=x1
    #pragma HLS INTERFACE ap_none port=y

    input_t in[2];
    result_t out[1];

  
    in[0] = x0;
    in[1] = x1;

    // Call the original hls4ml-generated top as a helper function
    myproject(in, out);

    y = out[0];
}

