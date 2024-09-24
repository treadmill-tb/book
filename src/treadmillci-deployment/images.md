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
$ wget -r -p -E -K -np -nH -nc --content-disposition --trust-server-names -i <(wget -O- -o/dev/null https://a.images.treadmill.ci/all.txt | sed 's|^\./|https://a.images.treadmill.ci/|')
```

## `vm-ubuntu-2204-amd64-uefi`

Versions:

| Build Date | git Revision                                                                                                                                          | Image ID                                                           |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| 2024-09-24 | [`f7f6a60239`](https://github.com/treadmill-tb/images/blob/f7f6a6023970684ab56515fcdedf1b5792f368f7/vm-ubuntu-2204-amd64-uefi/default.nix) | `4864215aff5840792f3f871cb74d0e74170b199406a56422612efa715e72e1a5` |

<details>
<summary>Build logs:</summary>

### f7f6a60239

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
| 2024-09-24 | [`f7f6a60239`](https://github.com/treadmill-tb/images/blob/f7f6a6023970684ab56515fcdedf1b5792f368f7/vm-ubuntu-2204-amd64-uefi/gh-actions-overlay.nix) | `0373bb7d728b36cb6083cfe12f27038b71972ceb90563b0037d4012df7b62bf4` |

<details>
<summary>Build logs:</summary>

### f7f6a60239

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

