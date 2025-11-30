# Proyecto VM Issabel en Azure (Opción A)

Este proyecto crea una VM Linux (AlmaLinux 8) en Azure, adecuada para instalar Issabel (PBX basada en Asterisk).
Incluye red, NSG con puertos relevantes para VoIP y administración, IP pública y NIC.

## Requisitos
- Azure CLI autenticado: `az login`
- Suscripción seleccionada: `az account show`

## Variables usadas (edita si lo deseas)
```
RG="rg-issabel"
LOC="westus2"
VNET="vnet-issabel"
SUBNET="snet-issabel"
NSG="nsg-issabel"
IP="pip-issabel"
NIC="nic-issabel"
VM="vm-issabel"
ADMIN="azureuser"
```

## Flujo de creación (Azure CLI)
1. Grupo de recursos
```
az group create -n $RG -l $LOC
```
2. Red virtual y subred
```
az network vnet create -g $RG -n $VNET -l $LOC --address-prefixes 10.20.0.0/16 \
  --subnet-name $SUBNET --subnet-prefixes 10.20.1.0/24
```
3. NSG y reglas mínimas
```
az network nsg create -g $RG -n $NSG
# SSH
az network nsg rule create -g $RG --nsg-name $NSG -n ssh-22 \
  --priority 1000 --access Allow --protocol Tcp --direction Inbound --source-address-prefixes Internet \
  --destination-port-ranges 22
# HTTP/HTTPS
az network nsg rule create -g $RG --nsg-name $NSG -n http-80 \
  --priority 1010 --access Allow --protocol Tcp --direction Inbound --source-address-prefixes Internet \
  --destination-port-ranges 80
az network nsg rule create -g $RG --nsg-name $NSG -n https-443 \
  --priority 1020 --access Allow --protocol Tcp --direction Inbound --source-address-prefixes Internet \
  --destination-port-ranges 443
# SIP 5060/5061
az network nsg rule create -g $RG --nsg-name $NSG -n sip-5060 \
  --priority 1100 --access Allow --protocol "*" --direction Inbound --source-address-prefixes Internet \
  --destination-port-ranges 5060
az network nsg rule create -g $RG --nsg-name $NSG -n sip-5061 \
  --priority 1110 --access Allow --protocol "*" --direction Inbound --source-address-prefixes Internet \
  --destination-port-ranges 5061
# RTP 10000-20000 (ajusta según diseño)
az network nsg rule create -g $RG --nsg-name $NSG -n rtp-10000-20000 \
  --priority 1200 --access Allow --protocol Udp --direction Inbound --source-address-prefixes Internet \
  --destination-port-ranges 10000-20000
```
4. IP pública y NIC
```
az network public-ip create -g $RG -n $IP --sku Standard --allocation-method Static
az network nic create -g $RG -n $NIC --vnet-name $VNET --subnet $SUBNET --network-security-group $NSG --public-ip-address $IP
```
5. Crear VM AlmaLinux 8 (gen2)
```
az vm create -g $RG -n $VM --image almalinux:almalinux:8-gen2:latest \
  --size Standard_B2s --admin-username $ADMIN --generate-ssh-keys \
  --nics $NIC --public-ip-sku Standard
```
6. Obtener IP pública
```
az vm list-ip-addresses -g $RG -n $VM -o table
```

## Post-instalación Issabel (dentro de la VM)
1. Conéctate por SSH: `ssh azureuser@<IP_PUBLICA>`
2. Actualiza el sistema y prepara dependencias:
```
sudo dnf -y update
sudo setenforce 0 || true
sudo dnf -y install wget curl tar net-tools firewalld
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=5060/udp
sudo firewall-cmd --permanent --add-port=5060/tcp
sudo firewall-cmd --permanent --add-port=5061/udp
sudo firewall-cmd --permanent --add-port=5061/tcp
sudo firewall-cmd --permanent --add-port=10000-20000/udp
sudo firewall-cmd --reload
```
3. Instala Issabel según la guía oficial/actualizada (revisa la documentación de Issabel para Alma/Rocky 8).

## Limpieza (opcional)
```
az group delete -n $RG --yes --no-wait
```
