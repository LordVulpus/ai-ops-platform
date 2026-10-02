# Cloud-Native Azure & DevOps Infrastructure Platform

A modular Azure infrastructure and containerized API platform built using Infrastructure as Code (Terraform), Kubernetes (AKS), and GitHub Actions. Designed with a focus on zero-trust security, containerized observability, and FinOps cost optimization.

## 📐 Architecture Diagram

```mermaid
graph TD
    Client[User / HTTP Request] -->|FastAPI Endpoint| AKS[Azure Kubernetes Service]
    
    subgraph Azure Cloud Environment
        AKS -->|Workload Identity| KV[Azure Key Vault]
        AKS -->|Scrapes Metrics| Prom[Prometheus Pod]
        Prom -->|Visualizes Data| Graf[Grafana Dashboard]
        
        Subnet[Private VNet / Subnet] --- AKS
    end
    
    subgraph CI/CD & IaC Pipeline
        GHA[GitHub Actions Workflow] -->|Terraform Plan / Apply| Azure[Azure Provisioning]
        GHA -->|Push Docker Image| ACR[Container Registry]
    end
