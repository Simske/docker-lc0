# Docker container for lc0 chess engine
This repository provides a tutorial as well as docker images for running the
neural net chess engine [LeelaZero](https://github.com/LeelaChessZero/lc0) and
conventional chess engine [Stockfish](https://stockfishchess.org/) on Linux.

Using the Docker containers makes installation and running the engines on cloud servers very easy.
To run lc0 efficiently a GPU is needed, but the CPU backends `eigen` and `openblas` are also supported in this image.
Stockfish is included to utilise the CPU as well.
(All supported backends: `cudnn-auto`, `cudnn`, `cudnn-fp16`, `cuda-auto`, `cuda`, `cuda-fp16`, `blas`, `eigen`)

The tutorial focuses on the Cloud machine provider [vast.ai](https://vast.ai/).

## Requirements
CPU with instruction set from Ivy Bridge or newer
For CUDA backends:
- Nvidia GPU with driver compatible with **CUDA 11.0** or higher
- `nvidia-container-runtime`

## Tags
Current version tags (all tags on one line point to same image):
- `latest`, `0.26`, `0.26.3`
- `latest-stockfish`, `0.26-stockfish`, `0.26.3-stockfish`

## Variations
The Docker images are based on the `nvidia/cuda` cudnn images, and two variations are provided:

 - `lc0` for Nvidia GPU
 - `lc0` for GPU and `stockfish` for CPU

The combined `lc0` and `stockfish` images are only sensible if you can only run a single container, as on vast.ai. Otherwise it would make more sense to run multiple containers.

All images are provided on DockerHub as [simske/lc0](https://hub.docker.com/r/simske/lc0) with the following tags:

 - `latest`
 - `latest-stockfish`

and for versions >=0.22 all four variants with the version instead of `latest`.

## Usage

### Running the container and loading network
`lc0` needs a weights file to run.
There is a selection of good networks on [lczero.org](https://lczero.org/play/bestnets/),
otherwise training networks from [training.lczero.org](https://training.lczero.org/networks/) can be used.

The container is shipped with the training image ID 591226, but if a different network is needed,
it can be set by setting the environment variable `$NETWORK` to the network URL,
or running the command `/lc0/set_network network_url` inside the container.

#### General
To run the image:
```
docker run -i --gpus=all -a STDIN -a STDOUT simske/lc0:latest
```
The networks are in the directory `/lc0/weights`, a docker volume can be mounted to this location to cache the downloaded networks.
To use a volume mount:
```
docker run -i --gpus=all -a STDIN -a STDOUT -v /lc0/weights -e NETWORK_HASH= simske/lc0:latest
```
Or for a directory mount (such that a weights directory is connected to a folder on the host machine):
```
docker run -i --gpus=all -a STDIN -a STDOUT -v /path/on/host:/lc0/weights -e NETWORK_HASH= simske/lc0:latest
```


#### vast.ai
To run lc0 on [vast.ai](https://vast.ai) create an account and make sure to have enough credit run a machine.
Then go to the Console->Create. Click on the button on the left "Edit Image & Config".
Select the custom image option with `simske/lc0:latest` (or the desired tag/version).

If a custom network should be used, it can be set with in the Onstart-Script with
```
set_network NETWORK_URL
```

### Connecting to the server
For connection to the chess server the SSH protocol is used.
This tutorial focuses on using Windows and ChessBase, the connection with Linux is much easier.

On Windows two components (in addition to chessbase) are needed:

 - SSH-Client [PuTTY](https://putty.org/) for the connection
 - [InBetween](https://www.chess.com/blog/AldoE/the-tale-of-the-lost-wrapper-inbetween-by-odd-gunnar-malin)
   as an adaptor between PuTTY and Chessbase

First make sure that you can connect to the server with PuTTY without using a password.
For this a SSH key needs to be generated, and the public key has to be put on the server ([External tutorial](https://devops.ionos.com/tutorials/use-ssh-keys-with-putty-on-windows/)).
For this use it makes most sense to use a key without a passphrase.

On vast.ai the public key needs to be entered under Account->SSH Key.

After the server has been setup and started like described in the sections above



### Inbetween

UCI-compliant communication between server and local chess program can be achieved

by the Inbetween program. Before execution the path to the private key as well as server host name and port have to be added in the Inbetween.ini file.

### Usage in Chessbase

For Lc0 a new UCI-Engine with the path directing to the inbetween.exe file has to be created.

If using a GPU with Turing architecture it is recommended to change the backend in the

engine parameters to "cudnn fp16". 3 threads are enough, apart from that the default settings are sufficient.

Further information can be found on https://lczero.org/.

For Stockfish another Inbetween-file and UCI-Engine need to be created. With regards to the engine parameters a higher amount of threads is recommended.



### Shortcut

The whole process can be automated using a script.

Don't forget to change the path to your private key as well as the base path variable and make sure to have Python installed in order to execute the script.
