package com.aristobot.data;

import java.io.Serializable;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "com.aristobot.data.EmailMessage")
public final class EmailMessage implements Serializable
{
	private static final long serialVersionUID = 1000;
	
	public static final String BODY_MIME_TYPE_TEXT = "text/plain";
	public static final String BODY_MIME_TYPE_HTML = "text/html";	
	
	public EmailMessage(String from, String to, String subject, String body, String bodyMimeType)
	{
		this.from = from;
		this.to = to;
		this.subject = subject;
		this.body = body;
		this.bodyMimeType = bodyMimeType;
	}
	
	public EmailMessage(String from, String to, String subject, String body)
	{
		this(from, to, subject, body, BODY_MIME_TYPE_TEXT);
	}
	
	public EmailMessage()
	{
		bodyMimeType = BODY_MIME_TYPE_TEXT;
	}
		
	public String from;
	public String to;
	public String subject;
	public String body;
	public String bodyMimeType;
	
	public String toString()
	{
		return from + " - " + to +  "- " + subject + " - " + bodyMimeType;
	}
	
	@Override
	public boolean equals(Object obj){
		if (obj == this) {
            return true;
        }
        if (obj == null || obj.getClass() != this.getClass()) {
            return false;
        }

        EmailMessage emailMessage = (EmailMessage) obj;
        return this.toString().equals(emailMessage.toString());
	}

	
	@Override
	public int hashCode(){
		return this.toString().hashCode();
	}
}
