package com.aristobot.data;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.OutgoingChatMessage")
public class OutgoingChatMessage 
{
	@XmlElement(required=false)
	public String conversationKey;
	
	@XmlElementWrapper(name="recipients")
    @XmlElement(name="String", required=false)
    public List<String> recipients;
	
	@XmlElement(required=true)
	public String message;
	
}
