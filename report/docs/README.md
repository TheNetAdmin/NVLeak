# NAP: Not (just) a Paper

The current template is created using: https://github.com/TheNetAdmin/nap/tree/49b7b3579c3f6819829812ab20f7972df582884e

NAP is a template for writing a research paper by providing:

   1. An extensible LaTeX template to accommodate templates from different conferences
   2. An Makefile-based system to auto generate plots based on data and code dependency
   3. A Docker image to build the NAP itself

## Usage

### With Docker

1. Build the docker image
   ```shell
   $ cd docker
   $ bash build.sh
   ```
2. Build the paper
   ```shell
   $ make docker-build
   ```

### With native tools

1. Install TeXLive
2. Install R, Python, and corresponding packages
   > Check the `docker/nap.Dockerfile` for packages
3. Build the paper
   ```shell
   $ make
   ```

## License

This code is released under MIT license.

### Create a paper repo

1. Create an empty GitHub repo for your paper, e.g., `GitHub_User/Paper_Name`.
2. Use the following one-liner to clone NAP, set up git remote to your new repo, and push to the repo.
   ```shell
   $ curl https://raw.githubusercontent.com/TheNetAdmin/nap/master/script/template/create_paper.sh | bash -s -- GitHub_User Paper_Name
   ```
3. (Optional) Set the GitHub default branch to `paper`, so that the `master` branch can be used to track upstream NAP updates.
4. (Optional) Link your GitHub repo to Overleaf
