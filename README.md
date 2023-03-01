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
 
### Test on CPU/GPU
<summary>To run the algorithm use this command</summary>

 ```sh
  ./main <path_img> <mode 0/1 CPU/GPU>
 ```

## Results

## Contributing

## License

## Contacts

Antonio Di Marino - University of Naples Parthenope - [email](antonio.dimarino001@studenti.uniparthenope.it) - [LinkedIn](https://www.linkedin.com/in/antonio-di-marino/)

Vincenzo Bevilacqua - University of Naples Parthenope - [email](vincenzo.bevilacqua001@studenti.uniparthenope.it)

## Acknowledgments

<p align="right">(<a href="#top">back to top</a>)</p>
