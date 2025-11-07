# Keycloak Deployment

## 🚀 Quick Start

### Step 1: Edit nginx.conf
```bash
nano nginx.conf
# Replace 'your-domain.com' with your domain (2 places)
```

### Step 2: Add SSL Certificates
```bash
mkdir -p ssl
cp /path/to/your/fullchain.pem ssl/
cp /path/to/your/privkey.pem ssl/
chmod 644 ssl/*.pem
```

### Step 3: Run Deployment
```bash
# Make script executable
chmod +x deploy-keycloak.sh

# Run deployment
./deploy-keycloak.sh

# Script will:
# - Validate nginx.conf and SSL certificates
# - Install Docker if needed
# - Create custom themes
# - Pull Docker images
# - Start all containers (PostgreSQL, Keycloak, Nginx)
```

**Access:** https://your-domain.com  
**Login:** admin / Admin@2025

---

## 📋 What You Need

| File | Action |
|------|--------|
| nginx.conf | Edit domain name |
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
