SSL Certificates
================

Replace these empty files with your actual SSL certificates:

1. fullchain.pem - Your SSL certificate (public)
2. privkey.pem - Your private key

Example:
--------
cp /path/to/your/certificate.crt fullchain.pem
cp /path/to/your/private.key privkey.pem
chmod 644 *.pem
