package com.aristobot.data;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.ApplicationData")
public class ApplicationData {
	
	public String contactURL;
	public String supportURL;
	public String currentVersion;
	public String updateURL;

}
