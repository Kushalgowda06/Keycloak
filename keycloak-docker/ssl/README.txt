SSL Certificate Instructions
============================

Replace the empty fullchain.pem and privkey.pem files with your actual SSL certificates.

Option 1: Using Certbot (Let's Encrypt)
----------------------------------------
sudo certbot certonly --standalone -d your-domain.com
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/
sudo chmod 644 ssl/*.pem

Option 2: Copy Existing Certificates
-------------------------------------
cp /path/to/your/fullchain.pem ssl/fullchain.pem
cp /path/to/your/privkey.pem ssl/privkey.pem
chmod 644 ssl/*.pem

Required Files:
- fullchain.pem: Full SSL certificate chain
- privkey.pem: Private key for the certificate

After adding certificates, run: ./deploy-keycloak.sh
