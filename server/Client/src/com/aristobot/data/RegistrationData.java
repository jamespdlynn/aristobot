package com.aristobot.data;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.RegistrationData")
public class RegistrationData 
{
	public String deviceId;
	
	public String registeredUsername;
	
	@XmlElementWrapper(name="defaultIcons")
	@XmlElement(name="com.aristobot.data.UserIcon")
	public List<UserIcon> defaultIcons;
	
	public ApplicationData appData;
	
	public String refreshToken;
	
}
