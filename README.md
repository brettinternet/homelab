# Homelab

[![Lint](https://github.com/brettinternet/homelab/actions/workflows/lint.yaml/badge.svg)](https://github.com/brettinternet/homelab/actions/workflows/lint.yaml)

Provisioning and experiments in my homelab. See also [homeops](https://github.com/brettinternet/homeops).

## Setup

[Install go-task](https://taskfile.dev/installation/). Then, setup age, precommit hooks and install repo dependencies:

```sh
task init
```

Run playbooks and commands:

```sh
task ansible:{init,list,setup,upgrade,status}
```

Deploy docker-compose remotely to hosts:

```sh
task docker:homelab run=up
```
