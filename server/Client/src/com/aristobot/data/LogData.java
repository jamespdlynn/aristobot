package com.aristobot.data;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.LogData")
public class LogData 
{
	public String deviceId;
	public String version;
	public String view;
	public String errorMessage;
	public String additionalInfo;
	
}
