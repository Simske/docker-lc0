# Docker container for lc0 chess engine



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