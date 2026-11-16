# Deployment Strategy Guide

This document outlines the strategies for safe and reliable deployment of the Volunteering (Добро.КГ) platform.

## 1. Blue-Green Deployment (Task #102)

Blue-Green deployment is a technique that reduces downtime and risk by running two identical production environments, only one of which (e.g., Blue) is serving production traffic.

### How to execute with Kubernetes:

1.  **Maintain Two Deployments**: Ensure you have `volunteers-backend-blue` and `volunteers-backend-green`.
2.  **Deployment Update**:
    - Update the **Green** deployment with the new image version.
    - Run automated tests against the Green service.
3.  **Traffic Switch**:
    - Update the `volunteers-backend` Service selector (or Ingress backend) to point to the `green` version.
    ```yaml
    # Update volunteers-backend service
    spec:
      selector:
        app: volunteers-backend
        version: green  # Switch this label from blue to green
    ```
4.  **Verification**: Confirm the new version is working. If issues occur, immediately switch the selector back to `blue`.
5.  **Cleanup**: Once Green is stable, keep Blue as a fallback or update it to match Green.

## 2. Database Migration Rollback (Task #103)

To ensure data integrity during updates, follow this migration strategy.

### Pre-deployment:
- **Always Backup**: Perform a database snapshot before running migrations.
- **Dry Run**: Test migrations on the Staging environment with a copy of production data.

### Rollback Procedure:

If a migration fails or causes issues:

1.  **Identify the last stable migration**:
    ```bash
    python manage.py showmigrations
    ```
2.  **Reverse common migrations**:
    ```bash
    # e.g., to rollback 'users' app to migration 0005
    python manage.py migrate users 0005
    ```
3.  **Handle Data Loss**: If a migration deleted columns/data, you **must restore from the pre-deployment backup**.
4.  **Blue-Green Sync**: If you rolled back the DB, ensure you also roll back the app version (switch back to Blue).

---
*Created as part of the DevOps Audit (102-103)*
