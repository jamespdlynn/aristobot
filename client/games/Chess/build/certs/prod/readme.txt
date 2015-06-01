
openssl genrsa -out prod.key 2048
openssl rsa -des3 -in prod.key -out prod.pem

openssl req -new -key prod.key -out CertificateSigningRequest.certSigningRequest  -subj "/emailAddress=info@aristobotgames.com, CN=Aristobot LLC., C=US"

openssl x509 -in ios_production.cer -inform DER -out ios_production.pem -outform PEM
openssl pkcs12 -export -inkey mykey.key -in ios_distribution.pem -out ios_distribution.p12

openssl x509 -in CertificateSigningRequest.certSigningRequest -inform DER -out android_distribution.pem -outform PEM
openssl pkcs12 -export -inkey mykey.key -in android_production.pem -out android_distribution.p12 -days 10000

rm android_

PSWD: fR0gg3r56!

(NOT SURE IF NEEDED)
copy /B aps.pem+prod.pem ck.pem


<iPhone> 
		<InfoAdditions><![CDATA[
			<key>UIDeviceFamily</key>
			<array>
				<string>1</string>
				<string>2</string>
			</array>
			<key>UIStatusBarStyle</key>
			<string>UIStatusBarStyleBlackOpaque</string>
		]]></InfoAdditions>
		
		<Entitlements><![CDATA[
			<key>get-task-allow</key>
			<true/>
			<key>aps-environment</key>
			<string>production</string>
			<key>application-identifier</key>
			<string>8PVSG6UN72.com.aristobot.chess</string>
			<key>keychain-access-groups</key>
			<array>
			    <string>8PVSG6UN72.*</string>
			 </array>
		]]></Entitlements>
		
		<requestedDisplayResolution>high</requestedDisplayResolution>

</iPhone>


