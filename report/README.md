# Reproduced Results

We use [NAP](https://github.com/TheNetAdmin/nap) template to generate a report with plots for reproduced results, and the reference data we ran on the Server B described in our main paper.

To build this report, we recommend using the [NAP Docker image](https://github.com/TheNetAdmin/nap/blob/master/docker/nap.Dockerfile):

```shell
$ cd docker && bash build.sh
$ make docker-build
# The generated report is `paper.pdf`
```

> Check `docs/README.md` or [NAP](https://github.com/TheNetAdmin/nap) for alternative approaches to build this report.
