package com.aristobot.data;

import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

@XmlRootElement(name = "com.aristobot.data.ChatMessage")
public class ChatMessage 
{
	@XmlTransient
	public int id;
	
	public String username;
	
	public String message;
	
	public RoboDate dateSent;
	
}
