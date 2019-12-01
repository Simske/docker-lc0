# Docker container for lc0 chess engine

## Variations
The Docker images are based on the nvidia/cuda cudnn images, and two variations are provided:

 - `lc0` for Nvidia GPU
 - `lc0` for GPU and `stockfish` for CPU

Because these images had problems with loading the SSH connections on the cloud computing marketplace [vast.ai](https://vast.ai) a second set of images is provided, with the base image `vastai/tensorflow`.

The combined `lc0` and `stockfish` images are only sensible if you can only run a single container, as on vast.ai. Otherwise it would make more sense to run multiple containers.

All images are provided on DockerHub as [simske/lc0](https://hub.docker.com/r/simske/lc0) with the following tags:

 - `latest`
 - `latest-stockfish`
 - `latest-vastai`
 - `latest-stockfish-vastai`

and for versions >=0.22 all four variants with the version instead of `latest`.

## Usage

### Running the container and loading network
`lc0` needs a training network to run, which can be obtained from [lczero.org/networks](https://lczero.org/networks/). The container has a builtin download script for the container, just the hash of the network needs to be given to the container.

The hash can be obtained by selecting a network, copying the download link which are in the form
`https://lczero.org/get_network?sha=b2acc2e7c7eb483760208c75668d56d55add204461371e61bbacff7ada7c2993`, the last part (after the equal sign) is the hash.
The LC0 wiki links to a [table of good networks](https://docs.google.com/spreadsheets/d/1XSJiCcQpCLv0fNwrUn7jXjdkZFU63YFEWpdXv6dSSg0).

#### General
To run the general cudnn version:
```
docker run --gpus=all -e NETWORK_HASH=b2acc2e7c7eb483760208c75668d56d55add204461371e61bbacff7ada7c2993 simske/lc0:latest
```
The networks are in the directory `/lc0/weights`, a docker volume can be mounted to this location to cache the downloaded networks.
To use a volume mount:
```
docker run --gpus=all -v /lc0/weights -e NETWORK_HASH= simske/lc0:latest
```
Or for a directory mount (such that a weights directory is connected to a folder on the host machine):
```
docker run --gpus=all -v /path/on/host:/lc0/weights -e NETWORK_HASH= simske/lc0:latest
```


#### vast.ai
To run lc0 on [vast.ai](https://vast.ai) create an account and make sure to have enough credit run a machine.
Then go to the Console->Create. Klick on the button on the left "Edit Image & Config".
Select the custom image option with `simske/lc0:latest-vastai` (or the desired tag/version, but always with vastai).

### Connecting to chess software

### SSH-connection

On Windows it is required to install the SSL-client Putty ("https://www.putty.org/").

When connecting to the server you have to authenticate with a public and private key pair.

How this is done is described in other sources, e.g. https://devops.ionos.com/tutorials/use-ssh-keys-with-putty-on-windows/.



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



