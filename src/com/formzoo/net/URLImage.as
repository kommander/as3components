package com.formzoo.net 
{
	import com.formzoo.utils.Helper;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	/**
	 * Simple Wrapper to Load multiple Images from an URL with retries
	 * 
	 * Todo: Look for queued urls before starting to load them,
	 * if an url is in the queue, wait for that object to load and take its bitmap,
	 * instead of loading the same url again in the queue.
	 * 
	 * @author Sebastian Herrlinger
	 */
	public class URLImage extends Sprite
	{
		private static var currentlyLoadingArr:Array = new Array();
		private static var imageCache:Array = new Array();
		private static var urlCache:Array = new Array();
		
		/** Timeout Event Type */
		public static const TIMEOUT:String = 'urlimage_timeout';
		
		/** The maximum number of loading retries */
		public static var maxSimultaneous:int = 3;
		
		/** The maximum number of loading retries */
		public static var maxRetries:int = 3;
		
		/** How long to wait until it retries to load in Milliseconds */
		public static var retryTime:int = 1000;
		
		/** The Time a loading Image is stopped in Milliseconds */
		public static var loadingTimeout:int = 30000;
		
		/** 
		 * How many images should be cached. Older images are removed if its limit is reached. 
		 * 0 is an infinite cache. 
		 */
		public static var cacheSize:int = 20;
		
		private var __bitmap:Bitmap = null;
		private var __loader:Loader = null;
		private var __url:URLRequest = null;
		private var __context:LoaderContext = null;
		private var __retries:int = 0;
		private var __queueTimeout:uint = 0x0;
		private var __timeout:uint = 0x0;
		
		public function URLImage(url:String = '', context:LoaderContext = null) {
			if (url != '')
				load(url, context);
		}
		
		public function load(url:String, context:LoaderContext = null, ignoreCache:Boolean = false):void
		{
			if (context == null)
				context = new LoaderContext(true);
			
			__url = new URLRequest(url);
			__context = context;
			
			if (!ignoreCache && urlCache.indexOf(url) != -1)
			{
				getBitmapFromCache(url);
				return;
			}
			
			__loader = new Loader();
			__loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete, false, 0, true); 
			__loader.contentLoaderInfo.addEventListener(Event.OPEN, routeEvent, false, 0, true); 
			__loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, error, false, 0, true);
			__loader.contentLoaderInfo.addEventListener(IOErrorEvent.DISK_ERROR, error, false, 0, true);
			__loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, error, false, 0, true);
			__loader.contentLoaderInfo.addEventListener(IOErrorEvent.VERIFY_ERROR, error, false, 0, true);
			
			update();			
		}
		
		private function getBitmapFromCache(url:String):void
		{
			__bitmap = new Bitmap((imageCache[urlCache.indexOf(url)] as URLImage).bitmap.bitmapData);
			addChild(__bitmap);
			var evt:Event = new Event(Event.COMPLETE);
			dispatchEvent(evt);
		}
		
		private function routeEvent(evt:Event):void
		{
			dispatchEvent(evt.clone());
		}
		
		private function update():void
		{
			if (currentlyLoadingArr.length == URLImage.maxSimultaneous) {
				__queueTimeout = setTimeout(update, 250);
				return;
			} else {
				__queueTimeout = 0x0;
			}
			URLImage.currentlyLoadingArr.push(this);
			__loader.cacheAsBitmap = true;
						
			executeLoad();
		}
				
		private function executeLoad():void
		{
			try {
				__loader.load(__url, __context);
				if (__timeout != 0x0)
					clearTimeout(__timeout);
				__timeout = setTimeout(timedOut, URLImage.loadingTimeout);
			} catch (e:Error) {
				error();
			}
		}
		
		private function complete(evt:Event):void
		{
			evt.stopImmediatePropagation()
			evt.stopPropagation();
			try {
				__bitmap = evt.target.content;
				__bitmap.smoothing = true;
				addChild(evt.target.content);
				addToCache();
			} catch(e:Error){}
			dispatchEvent(evt.clone());
			done();
		}
		
		private function addToCache():void
		{
			imageCache.push(this);
			urlCache.push(__url.url);
			if (cacheSize != 0)
			{
				if (urlCache.length > cacheSize)
				{
					urlCache.shift();
					imageCache.shift();
				}
			}
		}
		
		private function done(evt:Event = null):void
		{
			clearTimeout(__timeout);
			removeFromQueue();
		}
		
		private function removeFromQueue():void
		{
			if(currentlyLoadingArr.indexOf(this) != -1)
				currentlyLoadingArr.splice(currentlyLoadingArr.indexOf(this), 1);
		}
		
		private function error(evt:IOErrorEvent = null):void
		{
			__retries++;
			if (evt != null){
				evt.stopImmediatePropagation()
				evt.stopPropagation();
			}
			if (__retries < maxRetries && evt.text.substr(7, 4) != '2035') {
				done();
				__queueTimeout = setTimeout(update, retryTime);
				return;
			}
			if(evt != null)
				dispatchEvent(evt.clone());
			else
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, true, false, 'The URLImage file "'+__url+'" could not be loaded'));
			done();
		}
		
		private function timedOut():void
		{
			dispatchEvent(new Event(URLImage.TIMEOUT));
			close();
		}
		
		public function close():void
		{
			if(__queueTimeout != 0x0)
				clearTimeout(__queueTimeout);
			done();
			__loader.close();
		}
		
		public static function get currLoadingNum():int
		{
			return currentlyLoadingArr.length;
		}
		
		public function get content():DisplayObject
		{
			return __loader.content;
		}
		
		public function get url():String
		{
			return __url.url;
		}
		
		public function get bitmap():Bitmap
		{
			return __bitmap;
		}
		
		public static function clearCache():void
		{
			imageCache = new Array();
			urlCache = new Array();
		}
		
		public function removeFromCache(image:URLImage):void
		{
			urlCache.splice(urlCache.indexOf(image.url), 1);
			imageCache.splice(imageCache.indexOf(image), 1);
		}
		
	}
	
}