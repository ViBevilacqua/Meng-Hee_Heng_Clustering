#include "utility.hpp"


void convertMatToChar(Mat img, unsigned char* out_img_b, unsigned char* out_img_g, unsigned char* out_img_r, int rows, int cols){

    for(int i=0; i<rows; i++){
        for(int j=0; j<cols; j++){
            out_img_b[i*cols+j] = img.at<Vec3b>(i,j)[0];
            out_img_g[i*cols+j] = img.at<Vec3b>(i,j)[1];
            out_img_r[i*cols+j] = img.at<Vec3b>(i,j)[2];
        }
    }

}

void convertCharToMat(Mat &img, unsigned char* out_img_b, unsigned char* out_img_g, unsigned char* out_img_r, int rows, int cols){

    for(int i=0; i<rows; i++){
        for(int j=0; j<cols; j++){
            img.at<Vec3b>(i,j) = Vec3b(out_img_b[i*cols+j], out_img_g[i*cols+j], out_img_r[i*cols+j]);
        }
    }

}

