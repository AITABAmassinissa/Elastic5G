# Modify and rebuild the RAN images

This document explains which files must be modified when changing the OpenAirInterface RAN behavior, build options, dependencies, or final Docker images.

The setup was tested with the OpenAirInterface `2025.w18` branch. More recent branches can also be tested, but Dockerfiles, image tags, or Helm chart values may need to be adapted.

## Files to modify when changing the OAI RAN source code

If you modify the OAI RAN source code, for example files under:

```bash
openairinterface5g/openair1/
openairinterface5g/openair2/
openairinterface5g/openair3/
openairinterface5g/executables/
openairinterface5g/cmake_targets/
```

then the `ran-build` image must be rebuilt, because it compiles the OAI binaries such as:

- `nr-softmodem` for the gNB,
- `nr-cuup` for the CU-UP,
- `nr-uesoftmodem` for the NR-UE.

Rebuild `ran-build`:

```bash
docker build \
  --target ran-build \
  --tag ran-build:latest \
  --file openairinterface5g/docker/Dockerfile.build.ubuntu22 \
  openairinterface5g
```

Then rebuild the required final image or images:

```bash
docker build \
  --target oai-gnb \
  --tag oai-gnb:2025.w18 \
  --file openairinterface5g/docker/Dockerfile.gNB.ubuntu22 \
  openairinterface5g

docker build \
  --target oai-nr-cuup \
  --tag oai-nr-cuup:2025.w18 \
  --file openairinterface5g/docker/Dockerfile.nr-cuup.ubuntu22 \
  openairinterface5g

docker build \
  --target oai-nr-ue \
  --tag oai-nr-ue:2025.w18 \
  --file openairinterface5g/docker/Dockerfile.nrUE.ubuntu22 \
  openairinterface5g
```

## Files to modify when changing build dependencies

If a new package or tool is required to compile OAI, modify:

```bash
openairinterface5g/docker/Dockerfile.base.ubuntu22
```

This file creates the `ran-base` image and installs the base build dependencies. It also runs:

```bash
./build_oai -I -w USRP --install-optional-packages
```

After modifying this file, rebuild the full chain:

```bash
docker build \
  --target ran-base \
  --tag ran-base:latest \
  --file openairinterface5g/docker/Dockerfile.base.ubuntu22 \
  openairinterface5g

docker build \
  --target ran-build \
  --tag ran-build:latest \
  --file openairinterface5g/docker/Dockerfile.build.ubuntu22 \
  openairinterface5g
```

Then rebuild the final RAN images that are needed.

## Files to modify when changing the compilation options

If you want to change what OAI compiles, modify:

```bash
openairinterface5g/docker/Dockerfile.build.ubuntu22
```

This file builds the RAN binaries using:

```bash
./build_oai -c --ninja \
  --eNB --gNB --RU --UE --nrUE \
  --build-lib "telnetsrv enbscope uescope nrscope" \
  -w SIMU --build-e2 --cmake-opt -Dxsmall=ON
```

Modify this file if you need to:

- add or remove build targets,
- change `build_oai` options,
- enable or disable specific OAI features,
- change E2/FlexRIC-related build options.

After modifying it, rebuild:

```bash
docker build \
  --target ran-build \
  --tag ran-build:latest \
  --file openairinterface5g/docker/Dockerfile.build.ubuntu22 \
  openairinterface5g
```

Then rebuild the required final image or images.

## Files to modify when changing the gNB image

If you want to change the final gNB container image, modify:

```bash
openairinterface5g/docker/Dockerfile.gNB.ubuntu22
```

This file creates the final `oai-gnb:2025.w18` image. It copies the compiled gNB binary from `ran-build`:

```bash
/oai-ran/cmake_targets/ran_build/build/nr-softmodem
```

It also copies the gNB entrypoint script:

```bash
openairinterface5g/docker/scripts/gnb_entrypoint.sh
```

Rebuild only the gNB image if you modify the final image packaging or the entrypoint:

```bash
docker build \
  --target oai-gnb \
  --tag oai-gnb:2025.w18 \
  --file openairinterface5g/docker/Dockerfile.gNB.ubuntu22 \
  openairinterface5g
```

## Files to modify when changing the CU-UP image

If you want to change the final CU-UP container image, modify:

```bash
openairinterface5g/docker/Dockerfile.nr-cuup.ubuntu22
```

This file creates the final `oai-nr-cuup:2025.w18` image. It copies the compiled CU-UP binary from `ran-build`:

```bash
/oai-ran/cmake_targets/ran_build/build/nr-cuup
```

It also uses the same gNB entrypoint script:

```bash
openairinterface5g/docker/scripts/gnb_entrypoint.sh
```

Rebuild only the CU-UP image if you modify the final image packaging or the entrypoint:

```bash
docker build \
  --target oai-nr-cuup \
  --tag oai-nr-cuup:2025.w18 \
  --file openairinterface5g/docker/Dockerfile.nr-cuup.ubuntu22 \
  openairinterface5g
```

## Files to modify when changing the NR-UE image

If you want to change the final NR-UE container image, modify:

```bash
openairinterface5g/docker/Dockerfile.nrUE.ubuntu22
```

This file creates the final `oai-nr-ue:2025.w18` image. It copies the compiled NR-UE binary from `ran-build`:

```bash
/oai-ran/cmake_targets/ran_build/build/nr-uesoftmodem
```

It also copies the NR-UE entrypoint script:

```bash
openairinterface5g/docker/scripts/nr_ue_entrypoint.sh
```

Rebuild only the NR-UE image if you modify the final image packaging or the entrypoint:

```bash
docker build \
  --target oai-nr-ue \
  --tag oai-nr-ue:2025.w18 \
  --file openairinterface5g/docker/Dockerfile.nrUE.ubuntu22 \
  openairinterface5g
```

## Import the rebuilt images into containerd

After rebuilding an image, import it again into the Kubernetes container runtime.

For the gNB:

```bash
docker save oai-gnb:2025.w18 -o /tmp/oai-gnb.tar
sudo ctr -n k8s.io images import /tmp/oai-gnb.tar
```

For the CU-UP:

```bash
docker save oai-nr-cuup:2025.w18 -o /tmp/oai-nr-cuup.tar
sudo ctr -n k8s.io images import /tmp/oai-nr-cuup.tar
```

For the NR-UE:

```bash
docker save oai-nr-ue:2025.w18 -o /tmp/oai-nr-ue.tar
sudo ctr -n k8s.io images import /tmp/oai-nr-ue.tar
```

Verify that the images are available:

```bash
sudo ctr -n k8s.io images list | grep -E 'oai-gnb|oai-nr-cuup|oai-nr-ue'
```
