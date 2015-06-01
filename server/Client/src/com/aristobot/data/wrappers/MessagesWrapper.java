package com.aristobot.data.wrappers;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;

import com.aristobot.data.SystemMessage;

/**
 * Due to a limitation in Jersey, one is not able to directly return a list or array of typed objects.
 * Instead I created this wrapper value object to hold lists of any objects that may need to be returned in bulk.
 * @author James
 *
 */
@XmlRootElement(name="com.aristobot.data.SystemMessagesWrapper")
public class MessagesWrapper 
{
	@XmlElementWrapper(name="messages")
	@XmlElement(name="com.aristobot.data.SystemMessage")
	public List<SystemMessage> messages;
	
	public Boolean hasUnreadMessages;
	
	public Boolean hasUnreadPriorityMessages;
	
}
