package com.aristobot.data.wrappers;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;

import com.aristobot.data.Opponent;

/**
 * Due to a limitation in Jersey, one is not able to directly return a list or array of typed objects.
 * Instead I created this wrapper value object to hold lists of any objects that may need to be returned in bulk.
 * @author James
 *
 */
@XmlRootElement(name="com.aristobot.data.OpponentsWrapper")
public class OpponentsWrapper 
{
	@XmlElementWrapper(name="opponents")
	@XmlElement(name="com.aristobot.data.Opponent")
	public List<Opponent> opponents;
	
}
