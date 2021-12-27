# Linux

[![Lint](https://github.com/brettinternet/linux/actions/workflows/lint.yml/badge.svg)](https://github.com/brettinternet/linux/actions/workflows/lint.yml)

```sh
make setup
```

Configure hosts and vars in `inventory.yml`. Then, sync hosts:

```sh
ansible-playbook sync.yml
```
