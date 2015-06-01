package com.aristobot.as3srserrvice.services
{

	import com.aristobot.as3srserrvice.events.FaultEvent;
	import com.aristobot.as3srserrvice.events.ResultEvent;
	import com.aristobot.data.IconsWrapper;
	import com.aristobot.data.UserIcon;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;

	public class IconService extends RestService
	{		
		public function IconService(url:String, apiKey:String, accessToken:String)
		{
			super(url, apiKey, null, accessToken);
		}
		
		public function getIcons(resultHandler:Function, faultHandler:Function = null):void
		{
			get("/icons", IconsWrapper, resultHandler, faultHandler);
		}
		
		public function getAllIcons(resultHandler:Function, faultHandler:Function = null):void
		{
			get("/admin/icons", IconsWrapper, resultHandler, faultHandler);
		}
		
		public function getIconsByLevel(level:int, resultHandler:Function, faultHandler:Function = null):void
		{
			get("/admin/icons/"+level, IconsWrapper, resultHandler, faultHandler);
		}
		
		public function validateIcon(icon:UserIcon, resultHandler:Function, faultHandler:Function = null):void
		{
			postObject("/admin/icons/validate", icon, resultHandler, faultHandler);
		}
		
		public function addIcon(icon:UserIcon, resultHandler:Function, faultHandler:Function = null):void
		{
			postObject("/admin/icons/add", icon, resultHandler, faultHandler);
		}
		
		public function updateIcon(icon:UserIcon, resultHandler:Function, faultHandler:Function = null):void
		{
			postObject("/admin/icons/update", icon, resultHandler, faultHandler);
		}
		
		public function deleteIcon(key:String, resultHandler:Function=null, faultHandler:Function=null):void
		{
			postText("/admin/icons/delete", key, resultHandler, faultHandler);
		}
		
		public function uploadIcon(file:File, iconKey:String, resultHandler:Function=null, faultHandler:Function=null):void
		{
			var request:URLRequest = new URLRequest(serviceURL+"/admin/icons/upload?iconKey="+iconKey);
			request.requestHeaders = headers;
			
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			
			file.addEventListener(IOErrorEvent.IO_ERROR, fileUploadError);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fileUploadError);
			file.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, fileUploadComplete);
			file.upload(request);
			
		}
		
		protected function fileUploadComplete(event:HTTPStatusEvent):void
		{
			var tempResultHandler:Function = resultHandler;
			var tempFaultHandler:Function = faultHandler;
			resultHandler = null;
			faultHandler = null;
			
			if (event.status == 200 && tempResultHandler != null){
				tempResultHandler(new ResultEvent(ResultEvent.RESULT));
			}
			else if (tempFaultHandler != null){
				tempFaultHandler(new FaultEvent(FaultEvent.FAULT, FaultEvent.UPLOAD_FAILED, "Error uploading icon"));
			}
			
			
		}
		
		protected function fileUploadError(event:Event):void
		{
			var tempResultHandler:Function = resultHandler;
			var tempFaultHandler:Function = faultHandler;
			resultHandler = null;
			faultHandler = null;
			
			if (tempFaultHandler != null){
				tempFaultHandler(new FaultEvent(FaultEvent.FAULT, FaultEvent.UPLOAD_FAILED, "Error uploading icon"));
			}
			
			faultHandler = null;
		}
		
		
		
	}
}