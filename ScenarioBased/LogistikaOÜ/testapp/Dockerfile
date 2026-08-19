FROM php:8-apache
RUN docker-php-ext-install mysqli

RUN apt-get update && apt-get install -y curl openssl && \
    curl -o /var/www/html/DigiCertGlobalRootG2.crt.pem https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem && \
    curl -o /var/www/html/MicrosoftRSARootCA2017.crt "https://www.microsoft.com/pkiops/certs/Microsoft%20RSA%20Root%20Certificate%20Authority%202017.crt" && \
    openssl x509 -inform DER -in /var/www/html/MicrosoftRSARootCA2017.crt -out /var/www/html/MicrosoftRSARootCA2017.crt.pem && \
    cat /var/www/html/DigiCertGlobalRootG2.crt.pem /var/www/html/MicrosoftRSARootCA2017.crt.pem > /var/www/html/azure-mysql-ca-bundle.pem
    
COPY index.php /var/www/html 