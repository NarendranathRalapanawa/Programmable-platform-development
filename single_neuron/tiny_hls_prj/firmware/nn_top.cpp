#include "myproject.h"
#include "parameters.h"

void nn_top(input_t x0, input_t x1, result_t &y) {
    #pragma HLS INTERFACE ap_ctrl_none port=return
    #pragma HLS INTERFACE ap_none port=x0
    #pragma HLS INTERFACE ap_none port=x1
    #pragma HLS INTERFACE ap_none port=y

    input_t in[2];
    result_t out[1];

    #pragma HLS ARRAY_PARTITION variable=in complete
    #pragma HLS ARRAY_PARTITION variable=out complete

    in[0] = x0;
    in[1] = x1;

    myproject(in, out);

    y = out[0];
}
