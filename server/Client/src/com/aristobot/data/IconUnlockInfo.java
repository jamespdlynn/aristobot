package com.aristobot.data;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Basic value object representing an Icon
 * @author James
 *
 */
@XmlRootElement(name="com.aristobot.data.UserIcon")
public class IconUnlockInfo {
	
	@XmlElement(required = true)
	public Boolean hasUnlockedIcon;
	
	@XmlElement(required = true)
	public float oldUnlockPercent;
	
	@XmlElement(required = true)
	public float newUnlockPercent;
	
	public UserIcon unlockedIcon;
	
	
	
}
