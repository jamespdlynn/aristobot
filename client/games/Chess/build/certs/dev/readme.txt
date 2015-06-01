
openssl genrsa -out dev.key 2048

openssl req -new -key dev.key -out CertificateSigningRequest.certSigningRequest  -subj "/emailAddress=info@aristobotgames.com, CN=Aristobot LLC., C=US"

----------------------------------------------------------------
openssl rsa -des3 -in dev.key -out dev.pem

openssl x509 -req -days 3650 -in CertificateSigningRequest.certSigningRequest -signkey dev.pem -out android_development.pem

openssl pkcs12 -export -inkey dev.key -in android_development.pem -out android_development.p12

openssl x509 -in ios_development.cer -inform DER -out ios_development.pem -outform PEM
openssl pkcs12 -export -inkey dev.key -in ios_development.pem -out ios_development.p12

del dev.pem
del android_development.pem
del ios_development.pem

PSWD: fR0gg3r56!

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
			<string>development</string>
			<key>application-identifier</key>
			<string>8PVSG6UN72.com.aristobot.chess</string>
			<key>keychain-access-groups</key>
			<array>
			    <string>8PVSG6UN72.*</string>
			 </array>
		]]></Entitlements>
		
		<requestedDisplayResolution>high</requestedDisplayResolution>

</iPhone>



