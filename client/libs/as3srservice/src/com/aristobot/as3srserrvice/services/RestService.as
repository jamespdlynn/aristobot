package com.aristobot.as3srserrvice.services
{
	
	import com.aristobot.as3srserrvice.events.FaultEvent;
	import com.aristobot.as3srserrvice.events.ResultEvent;
	import com.moralyx.xml.FleXMLer;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	public class RestService extends EventDispatcher
	{		
		protected var serviceURL:String;
		protected var _isRunning:Boolean;
		public function get isRunning():Boolean{
			return _isRunning;
		}
		
		protected var headers:Array;
		protected var serializer:FleXMLer;
		
		protected var resultHandler:Function;
		protected var faultHandler:Function;
		
		protected var dataString:String;
		protected var dataObj:Object;
		
		protected var request:URLRequest;
		protected var requestor:URLLoader;
		
		protected var parseClass:Class;
		
		protected var numRetryAttempts:int;
		
		protected var statusCode:int;
		
		protected var _apiKey:String;
		
		protected var _versionNumber:String;
		
		protected var _accessToken:String;
		
		protected var activeTimer:Timer;
		
		protected static const MIN_ACTIVE_TIME:Number = 5000;
		protected static const MAX_ACTIVE_TIME:Number = 30000;
		
		public function RestService(url:String, apiKey:String = null, versionNumber:String = null, accessToken:String=null) 
		{
			serviceURL = url;
			_apiKey = apiKey;
			_versionNumber = versionNumber;
			_accessToken = accessToken;		
			
			serializer = new FleXMLer();
			
			requestor = new URLLoader();
			
			activeTimer = new Timer(MIN_ACTIVE_TIME, MAX_ACTIVE_TIME/MIN_ACTIVE_TIME);
			activeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, errorHandler, false, 0, true);
			
			requestor.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, responseStatusHandler, false, 0, true);
			requestor.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			requestor.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			requestor.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);	
			
			createHeaders();
		}
		
		protected function createHeaders():void
		{
			headers = new Array();
			if (_apiKey) headers.push(new URLRequestHeader("API",_apiKey));
			if (_versionNumber) headers.push(new URLRequestHeader("VN", _versionNumber));
			if (_accessToken) headers.push(new URLRequestHeader("AC",_accessToken));
		}
		
		
		protected function get(path:String, resultObjectClass:Class = null, resultHandler:Function = null, faultHandler:Function = null):void
		{
			if (_isRunning){
				throwRunningError();
				return;
			}
			
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			
			request = new URLRequest(serviceURL+path);
			request.requestHeaders = headers;
			request.method = URLRequestMethod.GET;
			
			parseClass = resultObjectClass;
			
			numRetryAttempts = 0;
			makeRequest();
		}
		
		protected function post(path:String, bodyData:ByteArray = null, contentType:String = null, resultHandler:Function = null, faultHandler:Function = null):void
		{
			if (_isRunning){
				throwRunningError();
				return;
			}
			
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			
			request = new URLRequest(serviceURL+path);
			request.requestHeaders = headers;
			request.method = URLRequestMethod.POST;
			
			if (bodyData)request.data = bodyData;
			if (contentType)request.contentType = contentType;
			
			parseClass = null;
			
			numRetryAttempts = 0;
			makeRequest();
		}	
		
		public function cancel():void
		{
			if (_isRunning)
			{
				requestor.close();
				
				request = null;
				resultHandler = null
				faultHandler = null;
				
				parseClass = null;	
				_isRunning = false;
			}
		}
		
		protected function postObject(path:String, bodyObj:Object, resultHandler:Function = null, faultHandler:Function = null):void
		{
			if (!bodyObj){
				throw new Error("Object must not be null");
			}
			
			var serializedObject:XML = serializer.serialize(bodyObj);
			var bodyData:ByteArray = new ByteArray();
			bodyData.writeUTFBytes(cleanXML(serializedObject));
			bodyData.position = 0;
			
			post(path,  bodyData, "application/xml", resultHandler, faultHandler);
		}
		
		protected function postText(path:String, text:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			if (!text){
				throw new Error("Text must not be null");
			}
			
			var bodyData:ByteArray = new ByteArray();
			bodyData.writeUTFBytes(text);
			bodyData.position = 0;
			
			post(path, bodyData, "text/xml", resultHandler, faultHandler);
			
		}
		
		
		protected function makeRequest():void
		{	
			if (_isRunning){
				throw new Error("Request already running");
			}
			
			_isRunning = true;
			dataObj = null;
			
			activeTimer.start();
			requestor.load(request);
		}
		
		protected function responseStatusHandler(event:HTTPStatusEvent):void
		{
			if (!_isRunning) return;
			statusCode = event.status;
		}
		
		protected function completeHandler(event:Event):void
		{		
			if (!_isRunning) return;
			
			_isRunning = false;
			activeTimer.reset();
			
			dataString = requestor.data as String;
			if (isResponseSuccess())
			{
				
				try{
					dataObj = (parseClass) ? serializer.deserialize(new XML(requestor.data), parseClass) : requestor.data;
				}
				catch (error:Error){
					fault(FaultEvent.UNABLE_TO_PARSE_RESULT, "Unable to parse result.");
					return;
				}
				
				result(dataObj);	
			}
			else if (statusCode == 404){
				fault(FaultEvent.SERVICE_NOT_FOUND, "Unable to connect to given service.");
			}
			else if (statusCode == 500){
				fault(FaultEvent.SERVER_ERROR, "Server Error");
			}
			else{
				var messageSplit:Array = (dataString) ? dataString.split("::") : [];
				var status:String = (messageSplit.length > 0) ? messageSplit[0] as String : FaultEvent.SERVER_ERROR;
				var message:String = (messageSplit.length > 1) ? messageSplit[1] as String : "Server Error";
				
				fault(status, message);
			}
		}
		
		
		protected function errorHandler(event:Event):void
		{						
			if (!_isRunning) return;
			
			if (activeTimer.currentCount == 0 && numRetryAttempts < 1 && request)
			{
				setTimeout(function():void{
					numRetryAttempts++;
					requestor.load(request);
				}, 1500);
			}
			else{
				activeTimer.reset();
				requestor.close();
				_isRunning = false;
				fault(FaultEvent.CONNECTION_ERROR, "Connection error. Please check your internet connection and try again.");
			}	
		}
		
		protected function result(resultObj:Object):void
		{
			var resultEvent:ResultEvent = new ResultEvent(ResultEvent.RESULT, resultObj);
			var tempHandler:Function = resultHandler;
			
			resultHandler = null;
			faultHandler = null;
			
			if (tempHandler != null){
				tempHandler(resultEvent);
			}
			
			dispatchEvent(resultEvent);
		}
		
		protected function fault(faultCode:String, message:String = ""):void
		{			
			var faultEvent:FaultEvent;
			
			var tempHandler:Function = faultHandler;
			
			resultHandler = null;
			faultHandler = null;
			
			if (tempHandler != null){ 
				faultEvent = new FaultEvent(FaultEvent.FAULT, faultCode, message)
				tempHandler(faultEvent);
			}
			else{
				faultEvent = new FaultEvent(FaultEvent.UNHANLED_FAULT, faultCode, message)
			}			
			
			dispatchEvent(faultEvent);
		}
		
		
		protected function throwRunningError():void
		{
			throw new Error("Service already running");
		}
		
		protected function isResponseSuccess():Boolean
		{
			return (statusCode >= 200 && statusCode < 300);
		}
		
		protected function cleanXML(xml:XML):String{
			return xml.toXMLString().replace(/[\r\n\t]*/gim, '');
		}
		
	}
}