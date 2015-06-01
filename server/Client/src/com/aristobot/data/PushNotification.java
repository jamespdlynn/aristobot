package com.aristobot.data;

import java.io.Serializable;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.PushNotification")
public final class PushNotification implements Serializable
{
	private static final long serialVersionUID = 2000;
	
	public static final String GAME_PARAMS = "game";
	public static final String MESSAGE_PARAMS = "message";
	public static final String ICON_PARAMS = "icon";
	
	public PushNotification(){}
	
	public PushNotification(String username, String message, String params, int applicationId)
	{
		this.username = username;
		this.message = message;
		this.params = params;
		this.applicationId = applicationId;
		this.badgeOnly = false;
	}
	
	public PushNotification(String username, int applicationId)
	{
		this.username = username;
		this.applicationId = applicationId;
		this.badgeOnly = true;
	}
	
	@XmlElement(required=false)
	public String username = "";
	
	@XmlElement(required=true)
	public String message = "";
	
	@XmlElement(required=false)
	public String params = "";
	
	@XmlElement(required=true)
	public int applicationId;
	
	@XmlElement(required=false)
	public boolean badgeOnly;
	
	@Override
	public boolean equals(Object obj){
		if (obj == this) {
            return true;
        }
        if (obj == null || obj.getClass() != this.getClass()) {
            return false;
        }

        PushNotification pn = (PushNotification) obj;
        return username.equals(pn.username) && message.equals(pn.message) && params.equals(pn.params) && applicationId == pn.applicationId;
	}

	
	@Override
	public int hashCode(){
		return  (31 * username.hashCode()) + (31 * message.hashCode()) + (31 * params.hashCode()) + (31 * applicationId);
	}
}
