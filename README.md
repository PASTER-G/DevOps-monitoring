# DevOps Project - Мониторинг приложения

Этот проект демонстрирует полную настройку мониторинга тестового приложения с использованием Kubernetes, Prometheus, Grafana и Terraform.

## Архитектура

- **Kubernetes Cluster**: Minikube
- **Стек мониторинга**: kube-prometheus-stack (Prometheus, Grafana, Alertmanager)
- **Приложение**: Простое Python Flask приложение с метриками Prometheus

## Структура проекта
```
.
├── applications/
│ ├── app.py # Python Flask приложение
│ ├── Dockerfile # Docker образ приложения
│ └── requirements.txt # Зависимости Python
├── terraform/
│ ├── main.tf # Основная конфигурация Terraform
│ ├── kube-prometheus-stack.tf # Helm чарт для стека мониторинга
│ ├── test-application.tf # Ресурсы Kubernetes для тестового приложения
│ ├── .gitignore # Правила Git ignore для Terraform*
└── README.md
```
## Предварительные требования

- Minikube
- kubectl
- Helm
- Terraform

## Использование
1. Клонируйте репозиторий:
```bash
git clone https://github.com/PASTER-G/DevOps-monitoring.git
cd DevOps-monitoring
```
2. Запустите Minikube: 
```bash
minikube start
```
3. Соберите образ приложения: 
```bash
docker build -t test-monitored-app:latest ./applications/
```
4. Примените конфигурацию Terraform:
```bash
cd terraform
terraform init
terraform apply
```
5. Получите доступ к сервисам:
- Grafana: 
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 8080:80
```
- Prometheus: 
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```
- Тестовое приложение: 
```bash
kubectl port-forward svc/test-monitored-app-service 5000:5000
```

## Метрики

Приложение предоставляет метрики на эндпоинте `/metrics`.

## Что можно улучшить

- Добавить конфигурацию Alertmanager для уведомлений в Telegram
- Реализовать CI/CD пайплайн
- Добавить сбор логов с помощью Loki

## Автор

[PASTER-G](https://github.com/PASTER-G)