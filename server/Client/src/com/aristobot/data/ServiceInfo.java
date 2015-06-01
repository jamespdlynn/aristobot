package com.aristobot.data;

import javax.xml.bind.annotation.XmlRootElement;

import com.aristobot.utils.Constants;

@XmlRootElement(name = "ServiceInfo")
public class ServiceInfo {
	public String serverVersionNumber = Constants.CURRENT_VERSION_NUMBER;
	public String minimumAppVersionNumber = Constants.REQUIRED_VERSION_NUMBER;
}
