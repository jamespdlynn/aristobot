package com.aristobot.data;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Basic value object representing an Icon
 * @author James
 *
 */
@XmlRootElement(name="com.aristobot.data.UserIcon")
public class UserIcon {
	
	@XmlElement(required = false)
	public String iconKey;
	
	public String iconName;
	
	public int level;
		
	@XmlElement(required = false)
	public String iconURL;
	
	@XmlElement(required = false)
	public String badgeURL;
	
	@XmlElement(required = false)
	public int rank;
	
	@XmlElement(required = false)
	public int applicationId;
	
	@XmlElement(required = false)
	public String deviceType;
	
	@XmlElement(required = false)
	public Boolean isDefault;
	
}
