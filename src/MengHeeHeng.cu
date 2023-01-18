#include <cfloat>
#include <iostream>
#include <cstdlib>
#include <vector>
#include <opencv2/opencv.hpp>
#include <cmath>
#include <stdio.h>
#include "MengHeeHeng.cuh"
#include <cuda_runtime.h>
using namespace std;
using namespace cv;

/*

#define CHECK_CUDA_ERROR(val) check((val), #val, __FILE__, __LINE__)
template <typename T>
void check(T err, const char* const func, const char* const file,
           const int line)
{
    if (err != cudaSuccess)
    {
        std::cerr << "CUDA Runtime Error at: " << file << ":" << line
                  << std::endl;
        std::cerr << cudaGetErrorString(err) << " " << func << std::endl;
        // We don't exit when we encounter CUDA errors in this example.
        // std::exit(EXIT_FAILURE);
    }
}

#define CHECK_LAST_CUDA_ERROR() checkLast(__FILE__, __LINE__)
void checkLast(const char* const file, const int line)
{
    cudaError_t err{cudaGetLastError()};
    if (err != cudaSuccess)
    {
        std::cerr << "CUDA Runtime Error at: " << file << ":" << line
                  << std::endl;
        std::cerr << cudaGetErrorString(err) << std::endl;
        // We don't exit when we encounter CUDA errors in this example.
        // std::exit(EXIT_FAILURE);
    }
}

*/

__global__ void find2PixelGPU(unsigned char* img_b_device, unsigned char* img_g_device, unsigned char* img_r_device, float *meanPartial_device, short rows, short cols);
__global__ void updateClusterGPU(unsigned char* img_b_device, unsigned char* img_g_device, unsigned char* img_r_device, unsigned int *idCluster_device, unsigned int *meanUpdate_device, float *centroidi_device , short rows, short cols, short k);
__global__ void findFarPixelGPU(unsigned char* img_b_device, unsigned char* img_g_device, unsigned char* img_r_device, unsigned int* idCluster_device, float* centroidi_device, float* partialDist_device , short rows, short cols, short k);

void MengHeeHengGPU(unsigned char* img_host_b,
    unsigned char* img_host_g,
    unsigned char* img_host_r,
    Mat img_output,
    short rows,
    short cols){

      //unsigned char *cluster_b_device, *cluster_g_device, *cluster_r_device;
      float *meanPartial_host, *meanPartial_device;
      unsigned char *img_b_device, *img_g_device, *img_r_device;

      double maxDist = FLT_MIN;
      bool uscita;

      unsigned int size;

      dim3 num_blocks, num_threads_per_block(4,4);


      //TO-DO = inizializza num block e thread
      num_blocks.y = rows/num_threads_per_block.y+((rows%num_threads_per_block.y)==0? 0:1);
      num_blocks.x = cols/num_threads_per_block.x+((cols%num_threads_per_block.x)==0? 0:1);

      cout << "num_blocks.y: " << num_blocks.y<<endl;
      cout << "num_blocks.x: " << num_blocks.x<<endl;
      size=rows*cols*sizeof(unsigned char);
      cudaMalloc((void**)&img_b_device, size);
      cudaMalloc((void**)&img_g_device, size);
      cudaMalloc((void**)&img_r_device, size);

      //trasferimento img da host to device
      cudaMemcpy(img_b_device, img_host_b, size, cudaMemcpyHostToDevice);
      cudaMemcpy(img_g_device, img_host_g, size, cudaMemcpyHostToDevice);
      cudaMemcpy(img_r_device, img_host_r, size, cudaMemcpyHostToDevice);

      //TO-DO: TROVARE I 2 PIXEL CON DISTANZA MAX
      int size_meanPartial = 5*num_blocks.x*num_blocks.y*sizeof(float);
      meanPartial_host = (float*)malloc(size_meanPartial);
      cudaMalloc((void**)&meanPartial_device, size_meanPartial);

      int ShMemSize=5*num_threads_per_block.x*num_threads_per_block.y*sizeof(float);

      //1. Trovare i 2 pixel con i colori piu' distanti
      find2PixelGPU<<< num_blocks, num_threads_per_block, ShMemSize >>> (img_b_device, img_g_device, img_r_device, meanPartial_device, rows, cols);
      cudaDeviceSynchronize();
    
      cudaMemcpy(meanPartial_host, meanPartial_device , size_meanPartial, cudaMemcpyDeviceToHost);

      float *centroidi_host;
      int k = 2;
      centroidi_host = (float*)malloc(k*3*sizeof(float));
      
      for(int i=0; i<num_blocks.x*num_blocks.y; i++){
        if (meanPartial_host[i*5+4] > maxDist){
          maxDist = meanPartial_host[i*5+4];
          int indRow = static_cast<int>(meanPartial_host[i*5]);
          int indCol = static_cast<int>(meanPartial_host[i*5+1]);
          centroidi_host[0] = static_cast<float>(img_host_b[indRow*cols+indCol]);
          centroidi_host[1] = static_cast<float>(img_host_g[indRow*cols+indCol]);
          centroidi_host[2] = static_cast<float>(img_host_r[indRow*cols+indCol]);
          indRow = static_cast<int>(meanPartial_host[i*5+2]);
          indCol = static_cast<int>(meanPartial_host[i*5+3]);
          centroidi_host[3] = static_cast<float>(img_host_b[indRow*cols+indCol]);          
          centroidi_host[4] = static_cast<float>(img_host_g[indRow*cols+indCol]);   
          centroidi_host[5] = static_cast<float>(img_host_r[indRow*cols+indCol]);
        }
      }
      //cout<<"tra poco cudaFree(meanPartial_device)"<<endl;
      cudaFree(meanPartial_device);
      free(meanPartial_host);

      cout << "[GPU] Le medie trovate nei primi due centroidi sono media[0]= " << centroidi_host[0]  << " media[1]= " << centroidi_host[1]  << endl;
      cout << "[GPU] La maxDist = " << maxDist << endl;

      unsigned int *meanUpdate_host, *meanUpdate_device;
      unsigned int size_meanUpdate = k*4*sizeof(unsigned int);
      meanUpdate_host = (unsigned int*)malloc(size_meanUpdate);
      cudaMalloc((void**)&meanUpdate_device, size_meanUpdate);

      float *centroidi_device;
      cudaMalloc((void**)&centroidi_device, k*3*sizeof(float));

      unsigned int *idCluster_host, *idCluster_device;
      float *partialDist_host, *partialDist_device; //si usa nel do-while
      unsigned int size_idCluster = rows*cols*sizeof(unsigned int);
      idCluster_host = (unsigned int *)malloc(size_idCluster);
      cudaMalloc((void**)&idCluster_device, size_idCluster);

      cudaMemcpy(centroidi_device, centroidi_host, k*3*sizeof(float), cudaMemcpyHostToDevice);

      unsigned int ShMemSize_Update=4*k*sizeof(unsigned int);

      cudaMemset(meanUpdate_device, 0, size_meanUpdate);

      //2. Clustering per prossimita', cioe' raggruppare tutti i pixel dell'immagine nel cluster con distanza minima (cluster più vicino)
      updateClusterGPU<<<num_blocks, num_threads_per_block, ShMemSize_Update>>>(img_b_device, img_g_device, img_r_device, idCluster_device, meanUpdate_device, centroidi_device, rows, cols, k); //kernel
      cudaDeviceSynchronize();
      
      cudaMemcpy(meanUpdate_host, meanUpdate_device , size_meanUpdate, cudaMemcpyDeviceToHost);
      cudaMemcpy(idCluster_host, idCluster_device , size_idCluster, cudaMemcpyDeviceToHost);

      for(int i=0; i<k; i++){
        unsigned int numerator_b = meanUpdate_host[i];
        unsigned int numerator_g = meanUpdate_host[k+i];
        unsigned int numerator_r = meanUpdate_host[2*k+i];
        unsigned int denominator = meanUpdate_host[3*k+i];
 
        //cout << "[GPU] numerator_b = " << numerator_b << " numerator_g = " << numerator_g << " numerator_r = " << numerator_b << " denominator = " << denominator << endl;
        
        centroidi_host[i*3] = numerator_b / denominator; 
        centroidi_host[i*3+1] = numerator_g / denominator;
        centroidi_host[i*3+2] = numerator_r / denominator;

        //cout << "[GPU] Valori Centroidi del cluster " << i << " B: " << centroidi_host[i*3] << " G: " << centroidi_host[i*3+1] << " R: " << centroidi_host[i*3+2] << endl;
      }

     

      do{
        float d  = FLT_MIN;

        int ShMemSize_Far=4*num_threads_per_block.x*num_threads_per_block.y*sizeof(float);
        cudaFree(centroidi_device);
        cudaMalloc((void**)&centroidi_device, k*3*sizeof(float));
        cudaMemcpy(centroidi_device, centroidi_host, k*3*sizeof(float), cudaMemcpyHostToDevice);

        int sizePartialDist = 4*num_blocks.x*num_blocks.y*sizeof(float);
        partialDist_host = (float*)malloc(sizePartialDist);
        cudaMalloc((void**)&partialDist_device, sizePartialDist);

        //3. Tra tutti i cluster, trovare il pixel [x] avente la massima distanza [d] dalla propria media di cluster.
        findFarPixelGPU<<<num_blocks, num_threads_per_block, ShMemSize_Far>>>(img_b_device, img_g_device, img_r_device, idCluster_device, centroidi_device, partialDist_device , rows, cols, k);
        cudaDeviceSynchronize();
      
        cudaMemcpy(partialDist_host, partialDist_device, sizePartialDist, cudaMemcpyDeviceToHost);

        float x[3] = {0.0, 0.0, 0.0};

        for(int i=0; i<num_blocks.x*num_blocks.y; i++){
          
          if (partialDist_host[i*4+3] > d){
            d = partialDist_host[i*4+3];
            x[0] = partialDist_host[i*4];
            x[1] = partialDist_host[i*4+1];
            x[2] = partialDist_host[i*4+2];
          }
        }

        //Calcolare la distanza tra ogni coppia di cluster
        vector <double> distanzaCoppie;
        for(int i=0; i<k; i++){
          for(int j=i+1; j<k; j++){
            distanzaCoppie.push_back(sqrt(pow(centroidi_host[i*3] - centroidi_host[j*3], 2) + pow(centroidi_host[i*3+1]-centroidi_host[j*3+1], 2) + pow(centroidi_host[i*3+2]-centroidi_host[j*3+2], 2)));          
          }          
        }

        //4. Calcolare la media [q] tra tutte le distanze delle coppie di cluster
        double q = mean(distanzaCoppie)[0]; 

        //5. Calcolare la media [q] tra tutte le distanze delle coppie di cluster
        if( d > q/2){
          uscita = false;

          k++;
          ShMemSize_Update = 4*k*sizeof(unsigned int);
          centroidi_host = (float*)realloc(centroidi_host, k*3*sizeof(float));
          //Inizialmente si considera il valore del pixel [x] come rappresentante del nuovo cluster
          centroidi_host[(k-1)*3] = x[0];
          centroidi_host[(k-1)*3+1] = x[1];
          centroidi_host[(k-1)*3+2] = x[2];

          cudaFree(centroidi_device);
          cudaMalloc((void**)&centroidi_device, k*3*sizeof(float));
          cudaMemcpy(centroidi_device, centroidi_host, k*3*sizeof(float), cudaMemcpyHostToDevice);

          cudaFree(meanUpdate_device);
          meanUpdate_host = (unsigned int*)realloc(meanUpdate_host, ShMemSize_Update);
          cudaMalloc((void**)&meanUpdate_device, ShMemSize_Update);

          cudaMemset(meanUpdate_device, 0, ShMemSize_Update);

          
          ////Essendoci un nuovo cluster, per ogni pixel si ricalcola il cluster con distanza minima.
          updateClusterGPU<<<num_blocks, num_threads_per_block, ShMemSize_Update>>>(img_b_device, img_g_device, img_r_device, idCluster_device, meanUpdate_device, centroidi_device, rows, cols, k);
          cudaDeviceSynchronize();
          
          cudaMemcpy(meanUpdate_host, meanUpdate_device , ShMemSize_Update, cudaMemcpyDeviceToHost);
          cudaMemcpy(idCluster_host, idCluster_device , size_idCluster, cudaMemcpyDeviceToHost);

          for(int i=0; i<k; i++){
            unsigned int numerator_b = meanUpdate_host[i];
            unsigned int numerator_g = meanUpdate_host[k+i];
            unsigned int numerator_r = meanUpdate_host[2*k+i];
            unsigned int denominator = meanUpdate_host[3*k+i];
            
            centroidi_host[i*3] = numerator_b / denominator; 
            centroidi_host[i*3+1] = numerator_g / denominator;
            centroidi_host[i*3+2] = numerator_r / denominator;
          }

        }else
          uscita = true;
      //Se non e' stato creato un nuovo cluster allora termina la fase di costruzione dei cluster, altrimenti si torna a controllare l'ipotetica presenza di nuovi cluster
      }while(!uscita);

      //Quando i cluster sono stati costruiti, l'algoritmo di Mang-Heng Hee puo' essere considerato concluso, l'ultima cosa da fare e' salvare i cluster appena costruiti in una Mat di output,
      //Inserendo come valore di ogni pixel media del corrispettivo cluster con la rappresentazione di colore RGB.
      for(int i=0; i<rows; i++){
        for(int j=0; j<cols; j++){
          int ind_k = idCluster_host[i*cols+j];
          img_output.at<Vec3b>(i,j) = Vec3b( (unsigned char)centroidi_host[ind_k*3], (unsigned char)centroidi_host[ind_k*3+1], (unsigned char)centroidi_host[ind_k*3+2]);
        }
      }

      cout << "[GPU] Numero di Cluster trovati = " << k << endl;

      free(centroidi_host);
      free(idCluster_host);
      free(meanUpdate_host);
      free(partialDist_host);
      cudaFree(img_b_device);
      cudaFree(img_g_device);
      cudaFree(img_r_device);
      cudaFree(idCluster_device);
      cudaFree(centroidi_device);
      cudaFree(meanUpdate_device);
      cudaFree(partialDist_device);           
    }

    __global__ void findFarPixelGPU(unsigned char* img_b_device, unsigned char* img_g_device, unsigned char* img_r_device, unsigned int* idCluster_device, float* centroidi_device, float* partialDist_device , short rows, short cols, short k){
        extern __shared__ float sm_far[];

        int indexRow=threadIdx.y + blockIdx.y*blockDim.y;
        int indexCol=threadIdx.x + blockIdx.x*blockDim.x;

        if(indexRow<rows && indexCol<cols){
          
          int id = idCluster_device[indexRow*cols+indexCol];
          float b_val = (float)img_b_device[indexRow*cols+indexCol];
          float g_val = (float)img_g_device[indexRow*cols+indexCol];
          float r_val = (float)img_r_device[indexRow*cols+indexCol];

          float distanza = sqrt(pow(b_val-centroidi_device[id*3], 2) + pow(g_val-centroidi_device[id*3+1], 2) + pow(r_val-centroidi_device[id*3+2], 2));
          sm_far[(4*threadIdx.x)+(threadIdx.y*blockDim.x*4)] = b_val;
          sm_far[((4*threadIdx.x)+(threadIdx.y*blockDim.x*4))+1] = g_val;
          sm_far[((4*threadIdx.x)+(threadIdx.y*blockDim.x*4))+2] = r_val;
          sm_far[((4*threadIdx.x)+(threadIdx.y*blockDim.x*4))+3] = distanza;
          __syncthreads();

          if (threadIdx.x==0 && threadIdx.y==0) {

            float maxDist = FLT_MIN;

            for(int i=0; i<blockDim.y; i++){
              for (int j = 0; j < blockDim.x; j++) {          
                if( (i+blockIdx.y*blockDim.y)<rows && (j+blockIdx.x*blockDim.x)<cols && sm_far[((4*j)+(i*blockDim.x*4))+3] > maxDist){
                  maxDist = sm_far[((4*j)+(i*blockDim.x*4))+3];
                  b_val = sm_far[((4*j)+(i*blockDim.x*4))];
                  g_val = sm_far[((4*j)+(i*blockDim.x*4))+1];
                  r_val = sm_far[((4*j)+(i*blockDim.x*4))+2];                        
                }  
              }
            }

            partialDist_device[(4*blockIdx.x)+(blockIdx.y*gridDim.x*4)] = b_val;
            partialDist_device[((4*blockIdx.x)+(blockIdx.y*gridDim.x*4))+1] = g_val;
            partialDist_device[((4*blockIdx.x)+(blockIdx.y*gridDim.x*4))+2] = r_val;
            partialDist_device[((4*blockIdx.x)+(blockIdx.y*gridDim.x*4))+3] = maxDist;
          }   
        }
    }


    __global__ void updateClusterGPU(unsigned char* img_b_device, unsigned char* img_g_device, unsigned char* img_r_device, unsigned int *idCluster_device, unsigned int *meanUpdate_device, float *centroidi_device,  short rows, short cols, short k){

        extern __shared__ unsigned int sm_up[];

        int indexRow=threadIdx.y + blockIdx.y*blockDim.y;
        int indexCol=threadIdx.x + blockIdx.x*blockDim.x;

        if (threadIdx.x==0 && threadIdx.y==0) {
          for(int i = 0; i< k*4; i++){
            sm_up[i] = 0;
          }
        }


        if(indexRow<rows && indexCol<cols){

          float minDist = FLT_MAX;
          int idCluster;

          for(int i = 0; i<k; i++){
            float distanza = sqrt(pow((float)img_b_device[indexRow*cols+indexCol]-centroidi_device[i*3], 2) + pow((float)img_g_device[indexRow*cols+indexCol]-centroidi_device[i*3+1], 2) + pow((float)img_r_device[indexRow*cols+indexCol]-centroidi_device[i*3+2], 2));
            if(distanza < minDist){
              idCluster = i;
              minDist = distanza;
            }
          }

          idCluster_device[indexRow*cols+indexCol] = idCluster;

          __syncthreads();

          atomicAdd(&(sm_up[idCluster]), img_b_device[indexRow*cols+indexCol]);
          atomicAdd(&(sm_up[idCluster+1*k]), img_g_device[indexRow*cols+indexCol]);
          atomicAdd(&(sm_up[idCluster+2*k]), img_r_device[indexRow*cols+indexCol]);
          atomicAdd(&(sm_up[idCluster+3*k]), 1);
          
          __syncthreads();

          if (threadIdx.x==0 && threadIdx.y==0) {
            for(int j=0; j<k; j++){
              atomicAdd(&meanUpdate_device[j], sm_up[j]);
              atomicAdd(&meanUpdate_device[k+j], sm_up[k+j]);
              atomicAdd(&meanUpdate_device[2*k+j], sm_up[2*k+j]);
              atomicAdd(&meanUpdate_device[3*k+j], sm_up[3*k+j]);
            }        
          }    
       }
    }


    __global__ void find2PixelGPU(unsigned char* img_b_device, unsigned char* img_g_device, unsigned char* img_r_device, float *meanPartial_device, short rows, short cols){

        extern __shared__ float sm[];

        int indexRow=threadIdx.y + blockIdx.y*blockDim.y;
        int indexCol=threadIdx.x + blockIdx.x*blockDim.x;
        float maxDist = FLT_MIN;
        //if(indexRow == 384 && indexCol==214)
        //printf("blockIdx.x: %d, blockIdx.y: %d \t theadID.x: %d, threadID.y: %d \t indexRow: %d, indexCol: %d\n", blockIdx.x,blockIdx.y, threadIdx.x,threadIdx.y,indexRow,indexCol);           
        if(indexRow<rows && indexCol<cols){
                  //if(blockIdx.x == 56 && blockIdx.y == 56){
                 //   printf("theadID.x: %d, threadID.y: %d\n", threadIdx.x,threadIdx.y);
                //  }
            for(int k = indexRow; k<rows; k++){
              for(int w = indexCol+1; w<cols; w++){
                float distanza = sqrt(pow((float)img_b_device[indexRow*cols+indexCol]-img_b_device[k*cols+w], 2) + pow((float)img_g_device[indexRow*cols+indexCol]-img_g_device[k*cols+w], 2) + pow((float)img_r_device[indexRow*cols+indexCol]-img_r_device[k*cols+w], 2));
                if( distanza > maxDist )
                {
                    maxDist = distanza;
                    sm[(5*threadIdx.x)+(threadIdx.y*blockDim.x*5)]= (float)indexRow; //indicizzazione per accedere alla sm ogni thread deve salvare i suoi 5 risultati parziali
                    sm[((5*threadIdx.x)+(threadIdx.y*blockDim.x*5))+1] = (float)indexCol;
                    sm[((5*threadIdx.x)+(threadIdx.y*blockDim.x*5))+2] = (float)k;
                    sm[((5*threadIdx.x)+(threadIdx.y*blockDim.x*5))+3] = (float)w;
                    sm[((5*threadIdx.x)+(threadIdx.y*blockDim.x*5))+4] = maxDist;
                }
              }
            }

        }
        __syncthreads();

        if (threadIdx.x==0 && threadIdx.y==0) {
          maxDist = FLT_MIN;
          int max_i = 0;
          int max_j = 0;
          for(int i=0; i<blockDim.y; i++){
              for (int j = 0; j < blockDim.x; j++) {
                if(sm[((5*j)+(i*blockDim.x*5))+4] > maxDist){
                  maxDist = sm[((5*j)+(i*blockDim.x*5))+4];
                  max_j = j;
                  max_i = i;
                }
              }
          }

          //(i+blockIdx.y*blockDim.y)<rows && (j+blockIdx.x*blockDim.x)<cols && 
          if(maxDist != FLT_MIN){
            meanPartial_device[(5*blockIdx.x)+(blockIdx.y*gridDim.x*5)] = sm[((5*max_j)+(max_i*blockDim.x*5))]; //indicizzazione per accedere ai migliori 5 elementi che ogni blocco deve salvarsi
            meanPartial_device[(5*blockIdx.x)+(blockIdx.y*gridDim.x*5)+1] = sm[((5*max_j)+(max_i*blockDim.x*5))+1];
            meanPartial_device[(5*blockIdx.x)+(blockIdx.y*gridDim.x*5)+2] = sm[((5*max_j)+(max_i*blockDim.x*5))+2];
            meanPartial_device[(5*blockIdx.x)+(blockIdx.y*gridDim.x*5)+3] = sm[((5*max_j)+(max_i*blockDim.x*5))+3];
            meanPartial_device[(5*blockIdx.x)+(blockIdx.y*gridDim.x*5)+4] = sm[((5*max_j)+(max_i*blockDim.x*5))+4];
          }else{
            meanPartial_device[(5*blockIdx.x)+(blockIdx.y*gridDim.x*5)+4] = FLT_MIN;
          }
        }
    }

