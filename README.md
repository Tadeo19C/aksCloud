# 🚀 Despliegue de Blog Ghost en Azure Kubernetes Service (AKS) con Terraform

¡Bienvenido a este proyecto de Infraestructura como Código (IaC)! Aquí demostramos cómo desplegar una aplicación web moderna y escalable (Ghost CMS) utilizando las mejores prácticas de DevOps.

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white) ![Ghost](https://img.shields.io/badge/ghost-%2315171A.svg?style=for-the-badge&logo=ghost&logoColor=white)

## 📋 Descripción del Proyecto

Este repositorio contiene todo el código necesario para aprovisionar un cluster de Kubernetes gestionado en Microsoft Azure y desplegar automáticamente una plataforma de blogging completa.

### 🏗️ Arquitectura

El proyecto consta de dos capas principales:

1.  **Infraestructura (Terraform):**
    *   **Resource Group:** Contenedor lógico para todos los recursos.
    *   **Virtual Network (VNet) & Subnet:** Red aislada para seguridad.
    *   **AKS Cluster:** Cluster de Kubernetes gestionado con un nodo `Standard_B2s_v2` en la región `mexicocentral`.

2.  **Aplicación (Kubernetes Manifests):**
    *   **Ghost CMS:** Frontend de la aplicación (Deployment).
    *   **MySQL 8.0:** Base de datos relacional persistente (Deployment).
    *   **Persistent Volumes (PVC):** Almacenamiento duradero para datos y contenido multimedia.
    *   **Load Balancer:** Servicio que expone la aplicación a internet con una IP pública.

## 🛠️ Requisitos Previos

*   [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) instalado y autenticado.
*   [Terraform](https://www.terraform.io/downloads.html) instalado.
*   [Kubectl](https://kubernetes.io/docs/tasks/tools/) instalado.

## 🚀 Guía de Despliegue Rápido

Sigue estos pasos para levantar tu propio blog en minutos:

### 1. Clonar el Repositorio
```bash
git clone <URL_DEL_REPOSITORIO>
cd <NOMBRE_DEL_DIRECTORIO>
```

### 2. Aprovisionar Infraestructura
Navega a la carpeta de Terraform e inicia el despliegue:

```bash
cd terraform
terraform init
terraform apply -auto-approve
```
*Esto tardará unos 5-10 minutos mientras Azure crea los recursos.*

### 3. Conectar al Cluster
Una vez finalizado Terraform, obtén las credenciales:

```bash
az aks get-credentials --resource-group demo-aks-rg --name demo-aks-aks --overwrite-existing
```

### 4. Desplegar la Aplicación
Aplica los manifiestos de Kubernetes desde la raíz del proyecto:

```bash
cd ..
kubectl apply -f ghost.yaml
```

### 5. ¡Acceder a tu Blog!
Espera unos minutos a que se asigne la IP pública y verifica el servicio:

```bash
kubectl get service ghost --watch
```
Copia la `EXTERNAL-IP` y pégala en tu navegador. ¡Listo!

## 📂 Estructura del Proyecto

```
.
├── ghost.yaml          # Manifiesto K8s (Deployment, Service, PVC)
├── terraform/          # Código de Infraestructura
│   ├── main.tf         # Definición de recursos Azure
│   ├── variables.tf    # Variables configurables (Región, VM Size)
│   ├── providers.tf    # Configuración del proveedor Azure
│   └── outputs.tf      # Salidas de Terraform
└── README.md           # Documentación
```

## 🧹 Limpieza (Destruir Recursos)

Para evitar costos innecesarios, destruye la infraestructura cuando termines:

```bash
cd terraform
terraform destroy -auto-approve
```

---

