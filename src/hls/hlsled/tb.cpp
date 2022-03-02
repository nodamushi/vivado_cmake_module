#include "./hlsled.hpp"


int main(int argc, char **argv)
{
  ap_uint<3> o, expected(7);
  HlsLED(0, o);
  if (o.to_uint() != 7) {
    printf("Illegal value: expected 7, value %d\n", o.to_uint());
    return 1;
  }

  HlsLED(1, o);
  if (o.to_uint()  != 6) {
    printf("Illegal value: expected 6, value %d\n", o.to_uint());
    return 1;
  }

  HlsLED(2, o);
  if (o.to_uint()  != 5) {
    printf("Illegal value: expected 5, value %d\n", o.to_uint());
    return 1;
  }

  HlsLED(4, o);
  if (o.to_uint()  != 3) {
    printf("Illegal value: expected 3, value %d\n", o.to_uint());
    return 1;
  }

  HlsLED(7, o);
  if (o.to_uint() != 0) {
    printf("Illegal value: expected 0, value %d\n", o.to_uint());
    return 1;
  }
  return 0;
}
