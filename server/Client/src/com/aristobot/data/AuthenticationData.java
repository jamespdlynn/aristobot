package com.aristobot.data;

import java.io.Serializable;

import javax.persistence.Transient;

import com.aristobot.utils.Constants.DeviceType;
import com.aristobot.utils.Constants.WriteAccess;

public class AuthenticationData implements Serializable
{
	private static final long serialVersionUID = 1100;
	
	@Transient
	public Boolean isValid = false;
	
	public String apiKey;
	
	public String deviceId;
	
	public DeviceType deviceType;
		
	public String applicationName;
	
	public int applicationId;
	
	public String applicationVersion;
		
	public Boolean rankingEnabled;
		
	public WriteAccess writeAccess;
	
	public String username;
	
	public String refreshToken;
	
	public String pushNotificationToken;
	
	public String updateName;
	
	public String updateURL;
	
	
}
