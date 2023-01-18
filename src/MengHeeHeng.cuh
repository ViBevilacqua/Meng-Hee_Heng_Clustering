#include <cuda.h>
#include <opencv2/opencv.hpp>

using namespace cv;


void MengHeeHengGPU(
    unsigned char* img_host_b,
    unsigned char* img_host_g,
    unsigned char* img_host_r,
    Mat img_output,
    short rows,
    short cols);

