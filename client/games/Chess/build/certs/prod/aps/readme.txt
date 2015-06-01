
openssl genrsa -out aps.key 2048

openssl rsa -des3 -in aps.key -out aps.pem

openssl req -new -key aps.key -out APSCertificateSigningRequest.certSigningRequest  -subj "/emailAddress=info@aristobotgames.com, CN=Aristobot LLC., C=US"

---------------------------------------------------------------

openssl x509 -in aps_production.cer -inform DER -out aps_production.pem -outform PEM

openssl pkcs12 -export -inkey aps.key -in aps_production.pem -out aps_production.p12

openssl s_client -connect gateway.push.apple.com:2195 -cert aps.pem -key aps.key

del aps.pem
del aps_production.pem

PSWD: fR0gg3r56!

(NOT SURE IF NEEDED)
copy /B aps.pem+dev.pem ck.pem

