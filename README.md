
<p align="center">
<img src="verycat.gif" alt="drawing" width="200" />
</p>

# DotFiles

Here are my dotfiles and configs for programming on my machine.

## Automated script

`symlink.sh` is a bash script that automatically moves the files specified inside from `~/<file_path>` to `./data/<file_path>` and leaves a symlink at the original path. Obviously if the file does not exist at `~/<file_path>` but is in `./data/<file_path>` is just creates the symlink.

To use just run `./symlink.sh` or `bash symlink.sh`.
