#include <opencv2/opencv.hpp>

using namespace cv;
void convertMatToChar(Mat img, unsigned char* out_img_b, unsigned char* out_img_g, unsigned char* out_img_r, int rows, int cols);
void convertCharToMat(Mat &img, unsigned char* out_img_b, unsigned char* out_img_g, unsigned char* out_img_r, int rows, int cols);

