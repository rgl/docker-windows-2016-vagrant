This is a Docker on Windows Server 2016 Vagrant environment for playing with Windows containers.

# Usage

Install the [Base Windows Box](https://github.com/rgl/windows-2016-vagrant).

Install the required plugins:

```bash
vagrant plugin install vagrant-windows-update
vagrant plugin install vagrant-reload
```

Then launch the environment:

```bash
vagrant up
```

**NB** On my machine this takes about 1h to complete... but YMMV!

At the end of the provision the [examples](examples/) are run.

# Graceful Container Shutdown

**Windows containers cannot be gracefully shutdown,** either there is no shutdown notification or they are forcefully terminated after a while. Check the [moby issue 25982](https://github.com/moby/moby/issues/25982) for progress.

The next table describes whether a `docker stop --time 30 <container>` will graceful shutdown a container that is running a [console](https://github.com/rgl/graceful-terminating-console-application-windows/), [gui](https://github.com/rgl/graceful-terminating-gui-application-windows/), or [service](https://github.com/rgl/graceful-terminating-windows-service/) app.

| base image        | app     | behaviour                                                              |
| ----------------- | ------- | ---------------------------------------------------------------------- |
| nanoserver        | console | does not receive the shutdown notification                             |
| windowsservercore | console | receives the shutdown notification but is killed after about 5 seconds |
| nanoserver        | gui     | fails to run `RegisterClass` (there's no GUI support in nano)          |
| windowsservercore | gui     | receives the shutdown notification but is killed after about 5 seconds |
| nanoserver        | service | does not receive the shutdown notification                             |
| windowsservercore | service | does not receive the shutdown notification                             |

You can launch these example containers from host as:

```bash
vagrant execute -c '/vagrant/ps.ps1 examples/graceful-terminating-console-application/run.ps1'
vagrant execute -c '/vagrant/ps.ps1 examples/graceful-terminating-gui-application/run.ps1'
vagrant execute -c '/vagrant/ps.ps1 examples/graceful-terminating-windows-service/run.ps1'
```
