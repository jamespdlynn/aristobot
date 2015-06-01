package com.aristobot.data;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.DeviceData")
public class DeviceData 
{
	
	@XmlElement(required = true)
	public String deviceId;
	
	@XmlElement(required = true)
	public String deviceType;
	
	@XmlElement(required = false)
	public String os;
	
	@XmlElement(required = false)
	public String cpuArchitecture;
	
	@XmlElement(required = false)
	public int screenDPI;
	
	@XmlElement(required = false)
	public Boolean useGCM;
}
