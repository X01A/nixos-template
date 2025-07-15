# nixos template

nixos quick startup template

## Add nodes

Create new hosts in `hosts/${NAME}`, write hosts configuation

Install new hosts via

```
./scripts/kexec.sh root@{HOST_TO_INSTALL}
./scripts/install.sh ${NAME} /mnt
```

