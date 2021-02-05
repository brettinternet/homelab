![desktop screenshot](./docs/screenshot.png)

### Setup

```sh
make setup
```

Configure hosts and vars in `inventory.yml`. Then, sync hosts:

```sh
ansible-playbook sync.yml
```
