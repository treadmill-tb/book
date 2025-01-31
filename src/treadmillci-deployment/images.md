# treadmill.ci Public Images

For now, we manually update the index of all files on the image server:
```
[root@sns31:/var/www/a.images.treadmill.ci]# find -type f ! -path './image.txt' ! -path './all.txt' > all.txt
```

To create a mirror of this image store based on this index, you can
use the following bash snippet, which will create the Treadmill image
store structure (`images/` and `blobs/`) in your current directory and
download all files not already present:
```
$ wget -r -p -E -K -np -nH -nc --content-disposition --trust-server-names --no-http-keep-alive -i <(wget -O- -o/dev/null https://a.images.treadmill.ci/all.txt | sed 's|^\./|https://a.images.treadmill.ci/|')
```

## `vm-ubuntu-2204-amd64-uefi`

Versions:

| Build Date | git Revision                                                                                                                                          | Image ID                                                           |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| 2024-10-13 | [`68cfe43a22`](https://github.com/treadmill-tb/images/blob/68cfe43a225bf83bba4fe3fe11723bda7da9c45f/vm-ubuntu-2204-amd64-uefi/default.nix) | `616a372120b0afce9310a07c2e3b4c897b9cbccdfec4cf01ccbcca82c156ee05` |
| 2024-09-24 | [`f7f6a60239`](https://github.com/treadmill-tb/images/blob/f7f6a6023970684ab56515fcdedf1b5792f368f7/vm-ubuntu-2204-amd64-uefi/default.nix) | `4864215aff5840792f3f871cb74d0e74170b199406a56422612efa715e72e1a5` |

<details>
<summary>Build logs:</summary>

### `68cfe43a22`

```
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> git rev-parse HEAD
68cfe43a225bf83bba4fe3fe11723bda7da9c45f
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
/nix/store/fcssv6py0hh2p4hfd9w5h9pl5d3ysz5p-treadmill-store
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/6c/
blobs/6c/82/
blobs/6c/82/47/
blobs/6c/82/47/6c8247e4440a4f9a691f67643c1d2adf87d48b6c475bd7b83599851cec785164
images/61/
images/61/6a/
images/61/6a/37/
images/61/6a/37/616a372120b0afce9310a07c2e3b4c897b9cbccdfec4cf01ccbcca82c156ee05

sent 941,459,348 bytes  received 113 bytes  81,866,040.09 bytes/sec
total size is 941,229,060  speedup is 1.00
```


### `f7f6a60239`

```
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> git rev-parse HEAD
f7f6a6023970684ab56515fcdedf1b5792f368f7
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
/nix/store/1bjwlkjbxq7nal5sbll6snh9wc0ingbv-treadmill-store
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/
blobs/33/
blobs/33/31/
blobs/33/31/75/
blobs/33/31/75/33317569a76291991bb8dae68a08b2369221a229192eec1ad3227d38826da281
images/
images/48/
images/48/64/
images/48/64/21/
images/48/64/21/4864215aff5840792f3f871cb74d0e74170b199406a56422612efa715e72e1a5

sent 940,869,394 bytes  received 113 bytes  89,606,619.71 bytes/sec
total size is 940,639,236  speedup is 1.00
```

</details>

### `vm-ubuntu-2204-amd64-uefi` + GitHub Actions Runner

Versions:

| Build Date | git Revision                                                                                                                                          | Image ID                                                           |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| 2024-10-13 | [`68cfe43a22`](https://github.com/treadmill-tb/images/blob/68cfe43a225bf83bba4fe3fe11723bda7da9c45f/vm-ubuntu-2204-amd64-uefi/gh-actions-overlay.nix) | `9ac6e2f62fec7d41d81df9a3b2fc40f5b4efa3e94055ea43a83e29dc77b791ee` |
| 2024-09-24 | [`f7f6a60239`](https://github.com/treadmill-tb/images/blob/f7f6a6023970684ab56515fcdedf1b5792f368f7/vm-ubuntu-2204-amd64-uefi/gh-actions-overlay.nix) | `0373bb7d728b36cb6083cfe12f27038b71972ceb90563b0037d4012df7b62bf4` |

<details>
<summary>Build logs:</summary>

### `68cfe43a22`

```
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> git rev-parse HEAD
68cfe43a225bf83bba4fe3fe11723bda7da9c45f
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> nix-build gh-actions-overlay.nix
/nix/store/25p7sbadzw5rj7b1dz23zxacw0ri8nzr-image-store
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/06/
blobs/06/ff/
blobs/06/ff/9f/
blobs/06/ff/9f/06ff9fbb107733147c0ab2bd92efd4a2844b42c9ec60945d8e84de1b6194ed61
blobs/6c/82/47/6c8247e4440a4f9a691f67643c1d2adf87d48b6c475bd7b83599851cec785164
images/9a/
images/9a/c6/
images/9a/c6/e2/
images/9a/c6/e2/9ac6e2f62fec7d41d81df9a3b2fc40f5b4efa3e94055ea43a83e29dc77b791ee

sent 658,136,207 bytes  received 214,956 bytes  77,453,078.00 bytes/sec
total size is 1,599,080,209  speedup is 2.43
```

### `f7f6a60239`

```
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> git rev-parse HEAD
f7f6a6023970684ab56515fcdedf1b5792f368f7
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> nix-build gh-actions-overlay.nix
/nix/store/yzn9rhawqslvl8y7b55sq6n19lhlcxrx-image-store
leons@caesium ~/p/t/i/vm-ubuntu-2204-amd64-uefi (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/33/31/75/33317569a76291991bb8dae68a08b2369221a229192eec1ad3227d38826da281
blobs/9b/
blobs/9b/bc/
blobs/9b/bc/f6/
blobs/9b/bc/f6/9bbcf6d6a67886ac58b9d6cdbb87b49e1a14ebeb8b19b99279b3d73eacdf00b0
images/03/
images/03/73/
images/03/73/bb/
images/03/73/bb/0373bb7d728b36cb6083cfe12f27038b71972ceb90563b0037d4012df7b62bf4

sent 658,398,373 bytes  received 214,879 bytes  69,327,710.74 bytes/sec
total size is 1,598,752,529  speedup is 2.43
```

</details>

## `netboot-raspberrypi-nbd`

Versions:

| Build Date | git Revision                                                                                                                                          | Image ID                                                           |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| 2024-01-31 | [`920cbe203b`](https://github.com/treadmill-tb/images/blob/920cbe203b7ba34b571bedb1428b4f3b02cb04ca/netboot-raspberrypi-nbd/default.nix) | `718c28849d48e3fd9db6b17ce336bc532df8c3c32f4ac7e8b61a79b901f8f452` |
| 2024-12-06 | [`bbaa65b4de`](https://github.com/treadmill-tb/images/blob/bbaa65b4de28ce20a55d79ac877bd1f1d060b2ae/netboot-raspberrypi-nbd/default.nix) | `58353de2cc7e2e84417af32a32957c1c75a4c28f7c0471c4598233e92310e3bd` |
| 2024-10-30 | [`a4d1690d1e`](https://github.com/treadmill-tb/images/blob/a4d1690d1ef9c2e330a71237913279ab90ca545d/netboot-raspberrypi-nbd/default.nix) | `a1b25b7cd0cbea2abd2ee472761180049f31c736095f81c16c65a5877e9f2c44` |
| 2024-10-15 | [`6803d17a74`](https://github.com/treadmill-tb/images/blob/6803d17a74a4158e80fc6bc6fe44c64543ff0d15/netboot-raspberrypi-nbd/default.nix) | `5db0bcba4ca3295c83d8cb0318651b78469b90cda9f124011c2bd15a0f1f8999` |
| 2024-10-13 | [`68cfe43a22`](https://github.com/treadmill-tb/images/blob/68cfe43a225bf83bba4fe3fe11723bda7da9c45f/netboot-raspberrypi-nbd/default.nix) | `f0617619bfb9a459a42b70101af65ef6b8d34631955f1d46423674e9897f26fc` |
| 2024-10-12 | [`914501ec25`](https://github.com/treadmill-tb/images/blob/914501ec25617613d8bc4d5ca034438e3030acf3/netboot-raspberrypi-nbd/default.nix) | `453facb39f3d786a3ab3075358665fca850025e5b342487066f7a5c5482bd8ab` |

<details>
<summary>Build logs:</summary>

### `920cbe203b`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
920cbe203b7ba34b571bedb1428b4f3b02cb04ca
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
fetching git input 'git+https://github.com/nix-community/fenix.git'
fetching git input 'git+https://github.com/treadmill-tb/treadmill.git'
/nix/store/2id5l0w2vljdakvibpz89q86r9q5wcbn-treadmill-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/d0/
blobs/d0/99/
blobs/d0/99/e8/
blobs/d0/99/e8/d099e857f6266da7e1e2a49064ebd6e3a62643a39eee2b4aa5b95ea298e0ba08
blobs/fa/
blobs/fa/cf/
blobs/fa/cf/df/
blobs/fa/cf/df/facfdfe0c346d9debf4e7e0ee12417bad93474d4dc5b26eb8583e9933383db96
images/71/
images/71/8c/
images/71/8c/28/
images/71/8c/28/718c28849d48e3fd9db6b17ce336bc532df8c3c32f4ac7e8b61a79b901f8f452

sent 2,157,971,643 bytes  received 148 bytes  88,080,481.27 bytes/sec
total size is 2,157,444,243  speedup is 1.00
```

### `bbaa65b4de`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
bbaa65b4de28ce20a55d79ac877bd1f1d060b2ae
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build  -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
/nix/store/h45xlb381jcsllh3dx54rf8ddz0zxday-treadmill-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/bb/07/46/bb074607e34ca760c9ad00f01931fff05e8ed34d8a01d2413ae9e95ce87fe298
blobs/c9/12/05/c9120536872e66511d2fe089fd4949b0a1289536b54f9a2cc5c16605b0f7e941
images/58/
images/58/35/
images/58/35/3d/
images/58/35/3d/58353de2cc7e2e84417af32a32957c1c75a4c28f7c0471c4598233e92310e3bd

sent 217,993 bytes  received 378,398 bytes  51,860.09 bytes/sec
total size is 2,148,990,099  speedup is 3,603.32
```

### `a4d1690d1e`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
a4d1690d1ef9c2e330a71237913279ab90ca545d
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
/nix/store/nakjliab1q6cd0l3f1v2zl3c65wghfl7-treadmill-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/6a/
blobs/6a/d5/
blobs/6a/d5/57/
blobs/6a/d5/57/6ad557ac9249f743b56124e0157b01e5cf28fcd5c45222b48ced16804b17eb09
blobs/9d/
blobs/9d/30/
blobs/9d/30/51/
blobs/9d/30/51/9d30513e0dc24566abb2271f269e6509db9866d313a5e0445e3afe9029542947
images/a1/
images/a1/b2/
images/a1/b2/5b/
images/a1/b2/5b/a1b25b7cd0cbea2abd2ee472761180049f31c736095f81c16c65a5877e9f2c44

sent 2,163,215,797 bytes  received 148 bytes  105,522,729.02 bytes/sec
total size is 2,162,687,123  speedup is 1.00
```

### `6803d17a74`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
6803d17a74a4158e80fc6bc6fe44c64543ff0d15
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build -I nixpkgs=https://github.com/nixos/nixpkgs/archive/release-24.05.tar.gz -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
/nix/store/b4vwspja2w7zp8slajn4zb6xydz6bdp8-treadmill-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/50/a3/39/50a339bb4ec10902d7bae426fe216a8008fca81fa82ce9a8036ebad998320c98
blobs/e4/4b/bd/e44bbd64b70c8afea5f704e8b6884f7d52bee81c75b84ac443bb77e45901acbf
images/5d/b0/bc/5db0bcba4ca3295c83d8cb0318651b78469b90cda9f124011c2bd15a0f1f8999

sent 217,190 bytes  received 378,929 bytes  51,836.43 bytes/sec
total size is 2,155,740,307  speedup is 3,616.29
```

### `68cfe43a22`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
68cfe43a225bf83bba4fe3fe11723bda7da9c45f
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
/nix/store/wc452qz6yp2fy7qdlk0sn71rbcsky45g-treadmill-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/33/24/
blobs/33/24/52/
blobs/33/24/52/3324528e034d27c28f4b58b734aab3e0b041a1c57c044bcef1a3c552ff88665a
blobs/50/
blobs/50/16/
blobs/50/16/df/
blobs/50/16/df/5016df56e359098cb3c6e44bee77ee390c71e855908e4b0a528cbf4ba5d37f4f
images/f0/
images/f0/61/
images/f0/61/76/
images/f0/61/76/f0617619bfb9a459a42b70101af65ef6b8d34631955f1d46423674e9897f26fc

sent 2,159,544,890 bytes  received 145 bytes  105,343,660.24 bytes/sec
total size is 2,159,017,107  speedup is 1.00
```

### `914501ec25`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
914501ec25617613d8bc4d5ca034438e3030acf3
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
/nix/store/8yhb8zc7n0dj1a1y9gc1n8l9w84firk8-treadmill-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/1d/67/24/1d6724e19dee478cc8b6b6e09cd8d3ba415818aac605acf4a7679159f246dcbf
blobs/44/a2/5a/44a25acaf1e384ffd6926d613cca854563bc62ad6515e1645ac4151f51c55054
images/45/
images/45/3f/
images/45/3f/ac/
images/45/3f/ac/453facb39f3d786a3ab3075358665fca850025e5b342487066f7a5c5482bd8ab
sent 222,162 bytes  received 385,681 bytes  52,855.91 bytes/sec
total size is 2,098,687,124  speedup is 3,452.68
```

</details>

### `netboot-raspberrypi-nbd` + GitHub Actions Runner

Versions:

| Build Date | git Revision                                                                                                                                          | Image ID                                                           |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| 2025-01-31 | [`920cbe203b`](https://github.com/treadmill-tb/images/blob/920cbe203b7ba34b571bedb1428b4f3b02cb04ca/netboot-raspberrypi-nbd/gh-actions-overlay.nix) | `3df57a5ee656ef85958e9cde04dd8ae44515b31efeef6a4d23ac3cd4d10a033c` |
| 2024-12-06 | [`bbaa65b4de`](https://github.com/treadmill-tb/images/blob/bbaa65b4de28ce20a55d79ac877bd1f1d060b2ae/netboot-raspberrypi-nbd/gh-actions-overlay.nix) | `441aa838c1fae3466cf682315aee44bcdb5c192054d6238e6c073ccd44b9bf06` |
| 2024-10-30 | [`a4d1690d1e`](https://github.com/treadmill-tb/images/blob/a4d1690d1ef9c2e330a71237913279ab90ca545d/netboot-raspberrypi-nbd/gh-actions-overlay.nix) | `df24da6c7a03d87b1b6b55162383a9dfdf48a129b5f3e648748f0f9d11cdb470` |
| 2024-10-15 | [`6803d17a74`](https://github.com/treadmill-tb/images/blob/6803d17a74a4158e80fc6bc6fe44c64543ff0d15/netboot-raspberrypi-nbd/gh-actions-overlay.nix) | `1b6900eff30f37b6d012240f63aa77a22e20934e7f6ebf38e25310552dc08378` |
| 2024-10-13 | [`68cfe43a22`](https://github.com/treadmill-tb/images/blob/68cfe43a225bf83bba4fe3fe11723bda7da9c45f/netboot-raspberrypi-nbd/gh-actions-overlay.nix) | `5f4b61324c27472b5354cd11229a0936320148cd6e852fbf05e1b7ff5b4598e6` |
| 2024-09-24 | [`914501ec25`](https://github.com/treadmill-tb/images/blob/914501ec25617613d8bc4d5ca034438e3030acf3/netboot-raspberrypi-nbd/gh-actions-overlay.nix) | `df8337148b0b3c63b400955b7ea49b202f34ecb111b61cd60c45a96076d9e31a` |

<details>
<summary>Build logs:</summary>

### `920cbe203b`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
920cbe203b7ba34b571bedb1428b4f3b02cb04ca
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build gh-actions-runner-overlay.nix
fetching git input 'git+https://github.com/nix-community/fenix.git'
fetching git input 'git+https://github.com/treadmill-tb/treadmill.git'
/nix/store/2nml7q6wg5qjqddxyi6qw0mfhaaihqcl-image-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/4d/
blobs/4d/96/
blobs/4d/96/8d/
blobs/4d/96/8d/4d968df944bd1ac0eb9e5409b2f118d94aeec254121afe93544a2952024768ec
blobs/d0/99/e8/d099e857f6266da7e1e2a49064ebd6e3a62643a39eee2b4aa5b95ea298e0ba08
blobs/fa/cf/df/facfdfe0c346d9debf4e7e0ee12417bad93474d4dc5b26eb8583e9933383db96
images/3d/
images/3d/f5/
images/3d/f5/7a/
images/3d/f5/7a/3df57a5ee656ef85958e9cde04dd8ae44515b31efeef6a4d23ac3cd4d10a033c

sent 3,365,664 bytes  received 379,052 bytes  325,627.48 bytes/sec
total size is 2,160,590,606  speedup is 576.97
```

### `bbaa65b4de`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
bbaa65b4de28ce20a55d79ac877bd1f1d060b2ae
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build gh-actions-runner-overlay.nix
/nix/store/nfjq0cwgxl2zb7w4gad3jjlcmzzxps7v-image-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/bb/
blobs/bb/07/
blobs/bb/07/46/
blobs/bb/07/46/bb074607e34ca760c9ad00f01931fff05e8ed34d8a01d2413ae9e95ce87fe298
blobs/c9/
blobs/c9/12/
blobs/c9/12/05/
blobs/c9/12/05/c9120536872e66511d2fe089fd4949b0a1289536b54f9a2cc5c16605b0f7e941
blobs/de/
blobs/de/3b/
blobs/de/3b/8d/
blobs/de/3b/8d/de3b8d4e4a3d07791693bb8a4a98a33f00d8f77b7b998ed49370d4f4eb3d3734
images/44/
images/44/1a/
images/44/1a/a8/
images/44/1a/a8/441aa838c1fae3466cf682315aee44bcdb5c192054d6238e6c073ccd44b9bf06

sent 2,424,375,783 bytes  received 183 bytes  107,750,042.93 bytes/sec
total size is 2,423,783,184  speedup is 1.00
```

### `a4d1690d1e`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main) [1]> git rev-parse HEAD
a4d1690d1ef9c2e330a71237913279ab90ca545d
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build gh-actions-runner-overlay.nix
/nix/store/v751jk869i22ppplffkrc0c5jvaqbivg-image-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/30/
blobs/30/1b/
blobs/30/1b/82/
blobs/30/1b/82/301b824fdf94fe658a389fdc6cf147e0ff4c1f06c4403a74d00331f6aebb1798
blobs/6a/d5/57/6ad557ac9249f743b56124e0157b01e5cf28fcd5c45222b48ced16804b17eb09
blobs/9d/30/51/9d30513e0dc24566abb2271f269e6509db9866d313a5e0445e3afe9029542947
images/df/24/
images/df/24/da/
images/df/24/da/df24da6c7a03d87b1b6b55162383a9dfdf48a129b5f3e648748f0f9d11cdb470

sent 470,751,703 bytes  received 379,466 bytes  32,491,804.76 bytes/sec
total size is 2,633,105,217  speedup is 5.59
```

### `6803d17a74`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
6803d17a74a4158e80fc6bc6fe44c64543ff0d15
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build -I nixpkgs=https://github.com/nixos/nixpkgs/archive/release-24.05.tar.gz gh-actions-runner-overlay.nix
/nix/store/148134wsj8h3jbaz6gn7dl1igywgg48a-image-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/50/a3/39/50a339bb4ec10902d7bae426fe216a8008fca81fa82ce9a8036ebad998320c98
blobs/e4/4b/bd/e44bbd64b70c8afea5f704e8b6884f7d52bee81c75b84ac443bb77e45901acbf
blobs/f8/
blobs/f8/d0/
blobs/f8/d0/61/
blobs/f8/d0/61/f8d06173c89ea48fb3c5214a7f16c3fb2c5964732602dcd230d535984d23e206
images/1b/
images/1b/69/
images/1b/69/00/
images/1b/69/00/1b6900eff30f37b6d012240f63aa77a22e20934e7f6ebf38e25310552dc08378

sent 470,030,344 bytes  received 378,961 bytes  30,348,987.42 bytes/sec
total size is 2,625,437,505  speedup is 5.58
```

### `68cfe43a22`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
68cfe43a225bf83bba4fe3fe11723bda7da9c45f
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build gh-actions-runner-overlay.nix
/nix/store/wcihc56rzaqhbvqj0amzza8qk6ss69sv-image-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/33/24/52/3324528e034d27c28f4b58b734aab3e0b041a1c57c044bcef1a3c552ff88665a
blobs/4f/
blobs/4f/5d/
blobs/4f/5d/5f/
blobs/4f/5d/5f/4f5d5fb9780430b4fa4b8747c74af7d60f8a4e1f5accb3cd9871d66bf674b8ca
blobs/50/16/df/5016df56e359098cb3c6e44bee77ee390c71e855908e4b0a528cbf4ba5d37f4f
images/5f/
images/5f/4b/
images/5f/4b/61/
images/5f/4b/61/5f4b61324c27472b5354cd11229a0936320148cd6e852fbf05e1b7ff5b4598e6

sent 469,637,168 bytes  received 379,189 bytes  30,323,635.94 bytes/sec
total size is 2,628,321,089  speedup is 5.59
```

### `914501ec25`

```
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> git rev-parse HEAD
914501ec25617613d8bc4d5ca034438e3030acf3
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> nix-build gh-actions-runner-overlay.nix
/nix/store/i0mqkn0ygp5zn7d1fd10h0z5msqav7vf-image-store
leons@caesium ~/p/t/i/netboot-raspberrypi-nbd (main)> rsync -rv -L result/ leons@sns31.cs.princeton.edu:/var/www/a.images.treadmill.ci/
sending incremental file list
image.txt
blobs/1d/
blobs/1d/67/
blobs/1d/67/24/
blobs/1d/67/24/1d6724e19dee478cc8b6b6e09cd8d3ba415818aac605acf4a7679159f246dcbf
blobs/44/
blobs/44/a2/
blobs/44/a2/5a/
blobs/44/a2/5a/44a25acaf1e384ffd6926d613cca854563bc62ad6515e1645ac4151f51c55054
blobs/55/
blobs/55/57/
blobs/55/57/dc/
blobs/55/57/dc/5557dc4e01ee4e2b4698931332b38a754c55f9da9ff48c7de8d4728fdf9683d1
images/df/
images/df/83/
images/df/83/37/
images/df/83/37/df8337148b0b3c63b400955b7ea49b202f34ecb111b61cd60c45a96076d9e31a
sent 2,570,257,715 bytes  received 183 bytes  100,794,427.37 bytes/sec
total size is 2,569,629,506  speedup is 1.00
```

</details>

