#!/bin/bash
# Keycloak Deployment Script
# Prerequisites: 
#   1. Edit nginx.conf - Replace 'your-domain.com' with your actual domain
#   2. Add SSL certificates to ssl/ folder (fullchain.pem, privkey.pem)

set -e

echo "=========================================="
echo " Keycloak Deployment"
echo "=========================================="
echo ""

# Validate prerequisites
echo "Validating prerequisites..."

# Check nginx.conf
if [ ! -f "nginx.conf" ]; then
    echo "nginx.conf not found!"
    echo "Please ensure nginx.conf is in the current directory"
    exit 1
fi

if grep -q "your-domain.com" nginx.conf; then
    echo " nginx.conf not configured!"
    echo ""
    echo "Please edit nginx.conf and replace 'your-domain.com' with your actual domain"
    echo "Example: nano nginx.conf"
    echo ""
    exit 1
fi

# Check SSL certificates
if [ ! -d "ssl" ]; then
    echo " ssl/ folder not found!"
    echo "Creating ssl/ folder..."
    mkdir -p ssl
    echo ""
    echo "Please add SSL certificates to ssl/ folder:"
    echo "  - ssl/fullchain.pem"
    echo "  - ssl/privkey.pem"
    echo ""
    exit 1
fi

if [ ! -f "ssl/fullchain.pem" ] || [ ! -f "ssl/privkey.pem" ]; then
    echo " SSL certificates not found!"
    echo ""
    echo "Please add the following files to ssl/ folder:"
    echo "  - ssl/fullchain.pem (SSL certificate)"
    echo "  - ssl/privkey.pem (Private key)"
    echo ""
    echo "Generate with certbot:"
    echo "  sudo certbot certonly --standalone -d your-domain.com"
    echo "  sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/"
    echo "  sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/"
    echo "  sudo chmod 644 ssl/*.pem"
    echo ""
    exit 1
fi

echo " Prerequisites validated"
echo ""

# Check Docker
echo " Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo " Docker installed"
else
    echo "Docker found"
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo apt update
    sudo apt install docker-compose -y
    echo " Docker Compose installed"
else
    echo " Docker Compose found"
fi
echo ""

# Extract domain from nginx.conf
echo " Reading configuration..."
DOMAIN_NAME=$(grep -m 1 "server_name" nginx.conf | grep -v "#" | awk '{print $2}' | tr -d ';')
echo "Domain: ${DOMAIN_NAME}"
echo ""

# Create keycloak themes
echo " Creating custom themes..."
mkdir -p keycloak-themes/AIOT/email/{html,text,messages}

cat > keycloak-themes/AIOT/theme.properties << 'EOF'
parent=base
import=common/keycloak
EOF

cat > keycloak-themes/AIOT/email/html/email-verification.ftl << 'EOF'
<#import "template.ftl" as layout>
<@layout.emailLayout>
<p>Dear ${user.firstName!"User"},</p>
<p>A new AIOT account has been registered with this email address (${user.email}). If it is you who initiated this registration, please verify your email address by clicking the link below:</p>
<p><a href="${link}">Verify Email Address</a></p>
<p>This link will expire in ${linkExpirationFormatter(linkExpiration)}.</p>
<p>Please ignore this message if its not you.</p>
<p>Thank you,<br>Autonomous ITOps Toolkit Team</p>
</@layout.emailLayout>
EOF

cat > keycloak-themes/AIOT/email/messages/messages_en.properties << 'EOF'
emailVerificationSubject=Autonomous ITOps Toolkit Verification email
emailVerificationBody=Someone has created a {2} account with this email address. If this was you, click the link below to verify your email address
emailVerificationBodyHtml=<p>Someone has created a {2} account with this email address. If this was you, click the link below to verify your email address</p><p><a href="{0}">Link to e-mail address verification</a></p><p>This link will expire within {3}.</p>
EOF
echo " Themes created"
echo ""

# Create docker-compose.yml
echo " Creating docker-compose.yml..."
cat > docker-compose.yml << EOF
version: '3.8'

services:
  keycloak-db:
    image: postgres:15
    container_name: keycloak-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: keycloak
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - internal
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U keycloak"]
      interval: 30s
      timeout: 10s
      retries: 5

  keycloak:
    image: quay.io/keycloak/keycloak:26.4.1
    container_name: keycloak
    restart: unless-stopped
    command: start
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://keycloak-db:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: keycloak
      KC_HOSTNAME: ${DOMAIN_NAME}
      KC_HOSTNAME_PORT: 443
      KC_HOSTNAME_STRICT: false
      KC_PROXY_HEADERS: xforwarded
      KC_HTTP_ENABLED: true
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: Admin@2025
    depends_on:
      keycloak-db:
        condition: service_healthy
    volumes:
      - ./keycloak-themes:/opt/keycloak/themes
    networks:
      - internal

  nginx:
    image: nginx:alpine
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - keycloak
    networks:
      - internal

volumes:
  postgres_data:

networks:
  internal:
    driver: bridge
EOF
echo " docker-compose.yml created"
echo ""

# Pull images
echo " Pulling Docker images..."
docker-compose pull
echo " Images pulled"
echo ""

# Start services
echo " Starting services..."
docker-compose up -d
echo " Services started"
echo ""

# Wait for services
echo " Waiting for services to start (60 seconds)..."
sleep 60

# Show status
echo ""
echo "=========================================="
echo " Service Status"
echo "=========================================="
docker-compose ps
echo ""

# Final message
echo "=========================================="
echo " Deployment Complete!"
echo "=========================================="
echo ""
echo " Access Keycloak:"
echo "   URL: https://${DOMAIN_NAME}"
echo "   Username: admin"
echo "   Password: Admin@2025"
echo ""
echo " Next Steps:"
echo "   1. Login to Admin Console"
echo "   2. Go to: Realm Settings → Themes"
echo "   3. Set Email Theme to: AIOT"
echo "   4. Configure SMTP: Realm Settings → Email"
echo ""
echo "🔧 Useful Commands:"
echo "   Logs:    docker-compose logs -f"
echo "   Stop:    docker-compose down"
echo "   Restart: docker-compose restart"
echo ""
