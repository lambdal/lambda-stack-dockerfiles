# Lambda Stack Dockerfiles

Dockerfiles with rolling-release Lambda Stack, designed for use with nvidia-container-toolkit

### Installing nvidia-container-toolkit

1) Ensure that you have a docker version > 19.03. On Ubuntu, you can simply run `sudo apt-get install docker.io`. On a different OS, or if you prefer to use upstream docker, follow [Docker's installation instructions](https://docs.docker.com/engine/install/ubuntu/)

2) If using Lambda Stack on your host machine, install nvidia-container-toolkit with `sudo apt-get install nvidia-container-toolkit`. Otherwise, follow [NVIDIA's installation instructions](https://github.com/NVIDIA/nvidia-docker)

### Building images

Build the image with the appropriate command for the distribution you wish to use.

```
sudo docker build -t lambda-stack:18.04 -f Dockerfile.bionic .
sudo docker build -t lambda-stack:20.04 -f Dockerfile.focal .
sudo docker build -t lambda-stack:22.04 -f Dockerfile.jammy .
```

Note that building these docker images requires acceptance of the [cuDNN license agreement](https://docs.nvidia.com/deeplearning/sdk/cudnn-sla/index.html)

### Testing images

Here's a simple PyTorch test to make sure that your GPUs are usable in your docker images

```
$ sudo docker run --gpus 2 lambda-stack:22.04 python3 -c "import torch; print(torch.cuda.device_count())"
2
```
