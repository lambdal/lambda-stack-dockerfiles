# Lambda Stack Dockerfiles

Dockefiles with rolling-release Lambda Stack, designed for use with nvidia-docker2

For Ubuntu 16.04, build with

```
sudo docker build -f Dockerfile.xenial .
```

For Ubuntu 18.04, build with

```
sudo docker build -f Dockerfile.bionic .
```

Building these docker images requires acceptance of the [cuDNN license agreement](https://docs.nvidia.com/deeplearning/sdk/cudnn-sla/index.html)
