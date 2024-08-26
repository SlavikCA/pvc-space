# pvc-space
Shell script shows PVC's size and free space

**Pre-requisite:**
- configured kubectl

**Limitations:**
- only shows info for PVC attached to running pods
- While testing on Harvester, I found that it only shows info about PVC for pods, but no info about PVC for VM discs. That's probably because their PVC are `VolumeMode: Block`.

Download script:
```
wget https://raw.githubusercontent.com/SlavikCA/pvc-space/main/pvc.sh; chmod +x pvc.sh
```

Use it:
```
./pvc.sh -h
Namespace                     PVC Size Used Avail Use%
"crm                  crm-ssd-pvc 4.6G 809M  3.7G  18%
"default                  vm-ub22 400G    0     0   0%
"elk-stack            logs500-pvc 492G 466G   26G  95%
"mysql            datadir-inno1-1  40G 8.5G   31G  22%
"mysql            datadir-inno1-0  40G 7.4G   32G  19%
"wordpress          wordpress-pvc 9.1G 4.5G  4.7G  49%
```
