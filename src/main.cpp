#include <iostream>
#include <cstdlib>
#include <ctime>
#include <cfloat>
#include <cuda.h>
#include "utility.hpp"
#include "MengHeeHeng.cuh"
#include "CudaTimer.cuh"
using namespace cv;
using namespace std;

void MengHeeHeng(Mat img, Mat &output);
void updateCluster(Mat img, Mat &idCluster, vector<vector<Vec3b> > &cluster, vector<Vec3b> &media);

int main(int argc, char * argv[])
{

    if(argc < 2)
    {
        cout << "Syntax Error, use: <./exec> <path_img> <mode 0/1 CPU/GPU>" << endl;
        exit(-1);
    }

    Mat img = imread(argv[1], IMREAD_COLOR); //BGR
    int rows = img.rows;
    int cols = img.cols;
    int mode = atoi(argv[2]);
    

    if(img.empty()){
        cerr<<"Load Image Failed!"<<endl;
        exit(1);
    }

    Mat img_output_MengCPU(rows, cols, CV_8UC3);
    Mat img_output_MengGPU(rows, cols, CV_8UC3);

    CudaTimer cuda_timer;

    if (mode == 0){ //CPU

        cuda_timer.start_timer();
        MengHeeHeng(img, img_output_MengCPU);
        cuda_timer.stop_timer();
        
        printf("Execution Time MangHengHee CPU : %f ms\n", cuda_timer.get_time());

        imwrite("MengHeeHeng_CPU_" + string(argv[1]), img_output_MengCPU);

    }
    else{ //GPU

    
        unsigned char *img_host_b = (unsigned char*)malloc(rows*cols*sizeof(unsigned char));
        unsigned char *img_host_g = (unsigned char*)malloc(rows*cols*sizeof(unsigned char));
        unsigned char *img_host_r = (unsigned char*)malloc(rows*cols*sizeof(unsigned char));

        convertMatToChar(img, img_host_b, img_host_g, img_host_r, rows, cols);

        unsigned char *img_out_host_b = (unsigned char*)malloc(rows*cols*sizeof(unsigned char)); //spazio per img output
        unsigned char *img_out_host_g = (unsigned char*)malloc(rows*cols*sizeof(unsigned char));
        unsigned char *img_out_host_r = (unsigned char*)malloc(rows*cols*sizeof(unsigned char));

        cuda_timer.start_timer();
        MengHeeHengGPU(img_host_b, img_host_g, img_host_r, img_output_MengGPU, rows, cols);
        cuda_timer.stop_timer();
        printf("Execution Time MangHengHee GPU : %f ms\n", cuda_timer.get_time());

        imwrite("MengHeeHeng_imp_GPU_custom_" + string(argv[1]), img_output_MengGPU);

        free(img_host_b);
        free(img_host_g);
        free(img_host_r);

    }


    cout << "End"<<endl;
    return 0;
}

//Funzione da parallelizzare
void updateCluster(Mat img, Mat &idCluster, vector<vector<Vec3b> > &cluster, vector<Vec3b> &media){
    Scalar med;

    for(int i = 0; i < img.rows; i++)
        for(int j = 0; j < img.cols; j++)
        {
            double minimo = DBL_MAX;
            int id;
            for(int k = 0; k < cluster.size(); k++)
            {
                double distanza = norm(media[k], img.at<Vec3b>(i,j));
                if( distanza < minimo )
                {
                    id = k;
                    minimo = distanza;
                }
            }
            idCluster.at<uchar>(i,j) = id;
            cluster[id].push_back(img.at<Vec3b>(i,j)); //host
        }
    //Si riaggiornano le medie dei cluster
    for (int i = 0; i < cluster.size(); i++)
    {
        med = mean(cluster[i]);
        Scalar sum = cv::sum(cluster[i]);
        cout << "[CPU] Cluster numerator values " << i << " B: " << sum[0] << " G: " << sum[1] << " R: " << sum[2] << endl;
        cout << "[CPU] Denominator: " << cluster[i].size() << endl;

        media[i] = Vec3b(med[0], med[1], med[2]);
        cout << "[CPU] Centroid values of the cluster " << i << " B: " << (int)media[i][0] << " G: " << (int)media[i][1] << " R: " << (int)media[i][2] << endl;
    }
}

void MengHeeHeng(Mat img, Mat &output)
{
    double maxDist = DBL_MIN;
    bool uscita;
    vector <vector <Vec3b> > cluster;
    vector <Vec3b> media;
    media.resize(2);
    cluster.resize(2);
    Mat idCluster(img.rows, img.cols, CV_8UC1);

    int i_max, j_max, k_max, w_max;

    //1. Trovare i 2 pixel con i colori piu' distanti DA PARALLELIZZARE
    for(int i = 0; i < img.rows; i+=1)
        for(int j = 0; j < img. cols; j+=1)
            for( int k = i; k < img.rows; k+=1)
                for(int w = j+1; w < img.cols; w+=1)
                {
                    double distanza = norm(img.at<Vec3b>(i,j), img.at<Vec3b>(k, w));
                    //double distanza = sqrt( pow(img.at<Vec3b>(i,j)[0] - img.at<Vec3b>(k, w)[0], 2) + pow(img.at<Vec3b>(i,j)[1] - img.at<Vec3b>(k, w)[1], 2) + pow(img.at<Vec3b>(i,j)[2] - img.at<Vec3b>(k, w)[2], 2));
                    if( distanza > maxDist)
                    {
                        maxDist = distanza;
                        media[0] = img.at<Vec3b>(i,j); //PuntoA
                        media[1] = img.at<Vec3b>(k,w); //PuntoB
                        i_max = i;
                        j_max = j;
                        k_max = k;
                        w_max = w;
                    }
                }

    cout << "[CPU] The averages found in the first two centroids are media[0]= " << media[0] << " media[1]= " << media[1] << endl;
    cout << "[CPU] maxDist = " << maxDist << endl;
    cout << "[CPU] Point A i = " << i_max << " j = " << j_max << " k = " << k_max << " w = " << w_max  << endl;
    //2. Clustering per prossimita', cioe' raggruppare tutti i pixel dell'immagine nel cluster con distanza minima (cluster più vicino)
    updateCluster(img, idCluster, cluster, media);

    
    do
    {
        //3. Tra tutti i cluster, trovare il pixel [x] avente la massima distanza [d] dalla propria media di cluster. DA PARALLELIZZARE
        double d  = DBL_MIN;
        Vec3b x;
        for(int k = 0; k < cluster.size(); k++)
            for(int w = 0; w < cluster[k].size(); w++)
            {
                double dist = norm(cluster[k][w], media[k]);
                if( dist > d){
                    d  = dist;
                    x = cluster[k][w];
                }
            }

        uscita = true; //da togliere alla fine

        cout << "[CPU] probable new centroid d: " << d << " x:" << x << endl;

        
        vector <double> distanzaCoppie;
        //Calcolare la distanza tra ogni coppia di cluster POTENZIALMENTE PARALLELIZZABILE MA FORSE NON CONVIENE FARLO
        for(int k = 0; k < cluster.size(); k++)
            for(int j = k+1 ; j < cluster.size(); j++)
                distanzaCoppie.push_back(norm(media[k], media[j]));

        //4. Calcolare la media [q] tra tutte le distanze delle coppie di cluster
        double q = mean(distanzaCoppie)[0];

        //5. Calcolare la media [q] tra tutte le distanze delle coppie di cluster
        if(d > q/2)
        {
            uscita = false;
            //Pulizia della struttura d'appoggio, dato che essendoci un nuovo cluster bisognera' ricalcolare il cluster di appartenenza di ogni pixel
            for (int i = 0; i< cluster.size(); i++)
                cluster[i].clear();

            cluster.resize(cluster.size()+1);
            //Inizialmente si considera il valore del pixel [x] come rappresentante del nuovo cluster
            media.push_back(x);

            //Essendoci un nuovo cluster, per ogni pixel si ricalcola il cluster con distanza minima.
            updateCluster(img, idCluster, cluster, media);
        }
        else
            uscita = true;
        
    //6. Se non e' stato creato un nuovo cluster allora termina la fase di costruzione dei cluster, altrimenti si torna a controllare l'ipotetica presenza di nuovi cluster
    }while(!uscita);

    //Quando i cluster sono stati costruiti, l'algoritmo di Mang-Heng Hee puo' essere considerato concluso, l'ultima cosa da fare e' salvare i cluster appena costruiti in una Mat di output,
    //Inserendo come valore di ogni pixel media del corrispettivo cluster con la rappresentazione di colore RGB.
    for(int i = 0; i < img.rows; i++)
        for(int j = 0; j < img. cols; j++)
          output.at<Vec3b>(i,j) = media[idCluster.at<uchar>(i,j)];

    cout << "Number of cluster: " << cluster.size() << endl;
    
}

