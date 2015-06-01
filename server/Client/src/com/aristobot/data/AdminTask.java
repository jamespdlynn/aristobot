package com.aristobot.data;

import java.io.Serializable;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.PushNotification")
public final class AdminTask implements Serializable
{
	private static final long serialVersionUID = 2000;
	
	public static enum Task{
		CLEAN, SEND_PENDING_NOTIFICATIONS, UPDATE_RANKINGS
	}
	
	public AdminTask(Task task)
	{
		this.task = task;
	}
	
	public AdminTask(Task task, Object data)
	{
		this.task = task;
		this.data = data;
	}
	
	@XmlElement(required=false)
	public Task task;
	public Object data;
	
}
