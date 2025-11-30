variable "prefix" {
  description = "Nombre base para los recursos"
  type        = string
  default     = "demo-aks"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "mexicocentral"
}

variable "node_count" {
  description = "Número de nodos del pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Tamaño de VM para el node pool"
  type        = string
  default     = "Standard_B2s_v2"
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes para AKS (opcional). Ej: 1.29.7"
  type        = string
  default     = null
}
