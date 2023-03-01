<div id="top">
  
  <div align="center">
    <a href="https://wfxr.mit-license.org/2017">
        <img src="https://img.shields.io/badge/License-MIT-brightgreen.svg"/>
    </a>
    <a href="https://gcc.gnu.org/">
        <img src="https://img.shields.io/badge/C++-11-blue.svg?style=flat&logo=c%2B%2B"/>
    </a>
    <a href="https://developer.nvidia.com/cuda-downloads">
        <img src="https://img.shields.io/badge/Cuda-10.0.130-76B900?style=flat&logo=NVIDIA&logoColor=76B900">
    </a>
    <a href="https://opencv.org/">
        <img src="https://img.shields.io/badge/OpenCV-3.3.1-5C3EE8?style=flat&logo=OpenCV&logoColor=FFFFFF"/>
    </a>
    <a href="https://cmake.org/">
        <img src="https://img.shields.io/badge/CMake-3.6.2-064F8C?style=flat&logo=CMake&logoColor=FFFFFF"/>
    </a>
    <a href="https://github.com/BananaCloud-CC2022-Parthenope/BananaCloud">
        <img src="https://img.shields.io/badge/Contributors-2-blue" alt="Contributors"/>
    </a>
  </div>
</div>

<br />
<h3 align="center">Meng-Hee Heng Clustering</h3>


  <p align="center">
    This repository is about our project, an iplementation of the Meng-Hee Heng clustering algorythm on cpu and in parallel on gpu. <br />
    Keep reading to find out how to do it. 
    <br />
    <a href="https://github.com/BananaCloud-CC2022-Parthenope/BananaCloud"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    ·
    <a href="https://github.com/BananaCloud-CC2022-Parthenope/BananaCloud/issues">Report Bug</a>
    ·
    <a href="https://github.com/BananaCloud-CC2022-Parthenope/BananaCloud/issues">Request Feature</a>
  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li><a href="#tests">Tests</a></li>
    <ul>
      <li><a href="#test-on-cpu/gpu">Test on CPU/GPU</a></li>
    </ul>
    <li><a href="#results">Results</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contacts">Contacts</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

In this work we implemented a variant of the <b>k-means</b> cluster algorithm, called <b>Meng-Hee Heng</b>. In this clustering algorithm unlike kmeans one does not have to give as input the number of k clusters that the algorithm has to find in the image, but found by the algorithm itself through a decision criterion.

In this repository there is both the sequential version run on CPU and the parallelized version run on GPU.

### Built With
* [CUDA](https://developer.nvidia.com/cuda-toolkit) - ver. 10.0.130
* [C++](https://gcc.gnu.org/) - ver. 11
* [OpenCV](https://opencv.org/) - ver. 3.3.1
* [CMake](https://cmake.org/) - ver. 3.6.2


## Tests
Commands to run CPU and GPU tests with related results are shown. 

<summary>Compile the cmake file</summary>
  
  ```sh
     cd src/
     cmake .
     make
  ```
 
 Assuming we have an image of Maradona in the **src** folder, these are the commands for clustering on CPU or GPU
 
### Test on CPU
<summary>To run the algorithm use this command</summary>

 ```sh
  ./main maradona.jpg 0
 ```
 
 Output of the algorithm executed on CPU
 
 <div align="center">
    <img src="images/MengHeeHeng_CPU_Maradona_640x551.jpg" alt="screen" >
 </div>
 
 
 
 ### Test on GPU
 
 For the execution of this algorithm we used a Quadro K5000 GPU.
 
<summary>To run the algorithm use this command</summary>

 ```sh
  ./main maradona.jpg 1
 ```

 Output of the algorithm executed on GPU
 
 <div align="center">
    <img src="images/MengHeeHeng_imp_GPU_custom_Maradona_640x551.jpg" alt="screen" >
 </div>
 
 The goal of the algorithm is not to have a better GPU result than the CPU result, but to have execution times in the GPU implementation orders of magnitude less than the CPU execution times.
 
 <p align="right">(<a href="#top">back to top</a>)</p>

## Results

In the following table it will be possible to observe the results obtained from running the algorithm on an image with different sizes.

|GPU                         |CPU                       |
|-------------------------------|-----------------------------|
|<table>  <thead>  <tr>  <th>Size</th>  <th>#Blocks</th> <th>Time</th> <th>#Cluster</th>  </tr>  </thead>  <tbody>  <tr>  <td>80x69</td>  <td>(18,20)</td>  <td>12,43 ms</td> <td>7</td></tr>   <tr> <td>160x138</td>  <td>(35,40)</td>  <td>131,08 ms</td> <td>8</td></tr>  <tr>  <td>320x276</td>  <td>(69,80)</td>  <td>1,96 sec</td> <td>7</td>  </tr> <tr> <td>**640x551**</td>  <td>**(138,160)**</td>  <td>**30,87 sec**</td> <td>**12**</td> </tr> <tr>  <td>1280x1102</td>  <td>(276,320)</td>  <td>8,17 min</td> <td>13</td></tr> </tbody>  </table> | <table>  <thead>  <tr>  <th>Size</th>  <th>Time</th> <th>#Cluster</th>  </tr>  </thead>  <tbody>  <tr>  <td>80x69</td>  <td>3,62 sec</td>  <td>7</td>  </tr>  <tr>  <td>160x138</td>  <td>50,16 sec</td>  <td>8</td>  </tr>  <tr>  <td>320x276</td>  <td>13,63 min</td>  <td>7</td></tr> <tr>  <td>**640x551**</td>  <td>**3,53 hours**</td>  <td>**12**</td></tr> <tr>  <td>1280x1102</td>  <td>N.A.</td>  <td>13</td></tr> </tbody>  </table>      |


## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.


## Contacts

Antonio Di Marino - University of Naples Parthenope - [email](antonio.dimarino001@studenti.uniparthenope.it) - [LinkedIn](https://www.linkedin.com/in/antonio-di-marino/)

Vincenzo Bevilacqua - University of Naples Parthenope - [email](vincenzo.bevilacqua001@studenti.uniparthenope.it)

<p align="right">(<a href="#top">back to top</a>)</p>
