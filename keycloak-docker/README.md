# Keycloak Deployment (ECR Version)

## 🚀 Quick Start

### Step 1: Edit nginx.conf
```bash
nano nginx.conf
# Replace 'your-domain.com' with your domain (3 places)
```

### Step 2: Add SSL Certificates
```bash
# Replace empty files with actual certificates
cp /path/to/your/fullchain.pem ssl/fullchain.pem
cp /path/to/your/privkey.pem ssl/privkey.pem
chmod 644 ssl/*.pem
```

### Step 3: Run Deployment
```bash
chmod +x deploy-keycloak.sh
./deploy-keycloak.sh
```

**Script automatically:**
- Validates configuration
- Installs Docker if needed
- Creates AIOT email theme
- Pulls images from ECR (public access, no authentication needed)
- Starts all 3 containers

**Access:** https://your-domain.com  
**Login:** admin / Admin@2025

---

## 📦 ECR Images Used

All images are pulled from AWS ECR (ap-south-1):

| Service | Image |
|---------|-------|
| PostgreSQL | 361568250748.dkr.ecr.ap-south-1.amazonaws.com/keycloak-postgres:15 |
| Keycloak | 361568250748.dkr.ecr.ap-south-1.amazonaws.com/keycloak:26.4.1 |
| Nginx | 361568250748.dkr.ecr.ap-south-1.amazonaws.com/keycloak-nginx:alpine |

**Note:** ECR repositories are configured for public access - no AWS credentials required to pull images.

---

## 📋 What You Need

| File | Action |
|------|--------|
| nginx.conf | Edit domain name (3 places) |
| ssl/fullchain.pem | Add SSL certificate |
| ssl/privkey.pem | Add private key |

---

## 🔧 Post-Deployment

1. Login to Admin Console
2. **Realm Settings** → **Themes** → Set Email Theme = `AIOT`
3. **Realm Settings** → **Email** → Configure SMTP (optional)

---

## 📊 Commands

```bash
# View logs
docker-compose logs -f

# Restart
docker-compose restart

# Stop
docker-compose down
```

---

## ❌ Troubleshooting

**nginx.conf not configured:** Edit nginx.conf and replace 'your-domain.com'  
**SSL not found:** Add fullchain.pem and privkey.pem to ssl/ folder  
**Permission denied:** Run `chmod +x deploy-keycloak.sh`  
**Port 80 in use:** Run `sudo fuser -k 80/tcp`  
**Image pull fails:** Ensure ECR repositories are public (check AWS Console → ECR → Permissions)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Nginx (Port 80/443)             │
│  - SSL Termination                      │
│  - Reverse Proxy                        │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│         Keycloak (Port 8080)            │
│  - Identity & Access Management         │
│  - Custom AIOT Email Theme              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      PostgreSQL (Port 5432)             │
│  - Keycloak Database                    │
│  - Persistent Volume                    │
└─────────────────────────────────────────┘
```

All containers run in isolated Docker network with persistent data storage.
