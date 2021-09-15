# Docker container for lc0 chess engine
This repository provides docker images for running the
neural net chess engine [LeelaZero](https://github.com/LeelaChessZero/lc0) on Linux.

The images are build for Nvidia GPUs, but CPU backends are also supported.
The startup script is able to automatically detect the number of GPUs in the system and configures `lc0` accordingly.
(Supported backends: `cudnn-auto`, `cudnn`, `cudnn-fp16`, `cuda-auto`, `cuda`, `cuda-fp16`, `blas`, `eigen`)

The evaluation network can be easily exchanged by prodiding an URL or the hash.

For convenience the binary for [Stockfish](https://stockfishchess.org/) is also included.

The images are confirmed to be compatible with the GPU renting service [vast.ai](https://vast.ai/).

## Requirements
CPU with instruction set from Ivy Bridge or newer
For CUDA backends:
- Nvidia GPU with driver compatible with **CUDA 11.2** or higher
- [`nvidia-container-runtime`](https://developer.nvidia.com/nvidia-container-runtime)

## Images
Images are available on [Dockerhub at simske/lc0](https://hub.docker.com/r/simske/lc0).

Current version tags (all tags on one line point to same image):
- `latest`, `0.28`, `0.28.0`
- `latest-stockfish`, `0.28-stockfish`, `0.28.0-stockfish`

## Variations
The Docker images are based on the `nvidia/cuda` cudnn images, and two variations are provided:

 - `lc0` for Nvidia GPU
 - `lc0` for GPU and `stockfish` for CPU

The combined `lc0` and `stockfish` images are only sensible if you can only run a single container, as on vast.ai. Otherwise it would make more sense to run a container for each engine.
## Networks
`lc0` needs a weights file to run.
There is a selection of good networks on [lczero.org](https://lczero.org/play/bestnets/),
otherwise training networks from [training.lczero.org](https://training.lczero.org/networks/) can be used.

The container is shipped with the default network 752187, but can be easily customized by setting the
environment variable `$NETWORK` for the container.
This can be either an URL to a network, or the SHA-hash of a training network.
The network will be downloaded on first use.
Networks are saved at `/lc0/weights`, this location can be mounted as a docker volume to avoid redownloading networks.

The network can also be set with
```
/lc0/set_network network_url
```

## Usage with docker directly
To run the image locally:
```
docker run -i --gpus=all -a STDIN -a STDOUT simske/lc0:latest
```
The networks are in the directory `/lc0/weights`, a docker volume can be mounted to this location to cache the downloaded networks.
To use a volume mount (with Leelenstein 15.0 network as an example):
```
docker run -i --gpus=all -a STDIN -a STDOUT -v /lc0/weights -e NETWORK=https://www.patreon.com/file?h=38164065&i=5788117 simske/lc0:latest
```
Or for a directory mount (such that a weights directory is connected to a folder on the host machine):
```
docker run -i --gpus=all -a STDIN -a STDOUT -v /path/on/host:/lc0/weights -e NETWORK=https://www.patreon.com/file?h=38164065&i=5788117 simske/lc0:latest
```


## Usage on vast.ai
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

## Contributing
If you encounter any issues or have suggestions for `docker-lc0` feel free to open issues and pull requests on this repository

## License
`docker-lc0` is licensed under the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
