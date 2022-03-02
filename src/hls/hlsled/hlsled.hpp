#ifndef HLS_LED_H__
#define HLS_LED_H__

#include <ap_int.h>
#include <hls_stream.h>

void HlsLED(ap_uint<3> i, ap_uint<3>& o);

#endif