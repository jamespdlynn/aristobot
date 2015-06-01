
openssl genrsa -out aps.key 2048

openssl req -new -key aps.key -out APSCertificateSigningRequest.certSigningRequest  -subj "/emailAddress=info@aristobotgames.com, CN=Aristobot LLC., C=US"

---------------------------------------------------------------

openssl rsa -des3 -in aps.key -out aps.pem

openssl x509 -in aps_development.cer -inform DER -out aps_development.pem -outform PEM
openssl pkcs12 -export -inkey aps.key -in aps_development.pem -out aps_development.p12

openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert aps_development.pem -key aps.key

del aps.pem
del aps_development.pem

PSWD: fR0gg3r

(NOT SURE IF NEEDED)
copy /B aps.pem+dev.pem ck.pem

