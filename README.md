# Provision

[![Lint](https://github.com/brettinternet/provision/actions/workflows/lint.yml/badge.svg)](https://github.com/brettinternet/provision/actions/workflows/lint.yml)

[Install go-task](https://taskfile.dev/installation/). Then, setup age, precommit hooks and install repo dependencies:

```sh
task init
```

Run playbooks and commands:

```sh
task ansible:{list,setup,upgrade,status,ping,uptime,reboot,poweroff}
```
