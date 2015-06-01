package com.aristobot.data;

import javax.persistence.Transient;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.SystemMessage")
public class SystemMessage 
{
	public String messageKey;
	public String subject;
	public String body;
	public UserIcon icon;
	public Boolean isPriority;
	public Boolean isRead;
	public String type;
	
	@Transient
	public int applicationId;
	
	

}
