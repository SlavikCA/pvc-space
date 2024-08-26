# pvc-space
Shell script shows PVC's size and free space

Pre-requisite: 
- configured kubectl

Limitation:
- only shows data for pods, which are running
- While testing on Harvester, I found that it shows no data for VM discs. Probably because their PVC are `VolumeMode: Block`

Usage example:
```
wget https://raw.githubusercontent.com/SlavikCA/pvc-space/main/pvc.sh
chmod +x pvc.sh
./pvc.sh -h
Namespace                 PVC Size Used Avail Use%
"crm              crm-ssd-pvc 4.6G 809M  3.7G  18%
"elk-stack        logs500-pvc 492G 466G   26G  95%
"mysql        datadir-inno1-1  40G 8.5G   31G  22%
"mysql        datadir-inno1-0  40G 7.4G   32G  19%
"wordpress      wordpress-pvc 9.1G 4.5G  4.7G  49%
```
