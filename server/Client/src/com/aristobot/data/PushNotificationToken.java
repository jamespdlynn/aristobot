package com.aristobot.data;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Simple wrapper value object containing user information sent up during login or registration.
 * Sent from the client to the server.
 * @author James
 *
 */
@XmlRootElement(name = "com.aristobot.data.PushNotificationToken")
public class PushNotificationToken 
{
	public String token;
	
    public Boolean isProduction;

}
