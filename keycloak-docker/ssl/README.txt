SSL Certificate Instructions
============================

Replace the empty fullchain.pem and privkey.pem files with your actual SSL certificates.

Copy Existing Certificates
-------------------------------------
cp /path/to/your/fullchain.pem ssl/fullchain.pem
cp /path/to/your/privkey.pem ssl/privkey.pem
chmod 644 ssl/*.pem

Required Files:
- fullchain.pem: Full SSL certificate chain
- privkey.pem: Private key for the certificate

After adding certificates, run: ./deploy-keycloak.sh
