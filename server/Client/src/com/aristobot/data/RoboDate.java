package com.aristobot.data;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;


@XmlRootElement(name = "com.aristobot.data.RoboDate")
public class RoboDate {
	
    @XmlElement(required = true)
    public String dateString;
    
    @XmlElement(required = true)
    public long timeAgo;
    
}
