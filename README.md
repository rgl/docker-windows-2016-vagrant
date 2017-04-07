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
