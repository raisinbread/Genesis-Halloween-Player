package
{
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	
	public class Face extends UIComponent
	{
		private var _rect:Rectangle;
		private var _file:File = null;
		private var _loader:Loader;
		private var _bobDistance:uint = 25;
		private var _bobTime:uint = 1;
		private var _bobbing:Boolean = false;
		
		public function Face(rect:Rectangle)
		{
			super();
			_loader = new Loader();
			_rect = rect;
			this.alpha = 1;
			this.visible = true;
		}
		
		public function activate():void {
			dispatchEvent(new Event(Event.ACTIVATE));
		}
		
		public function animateWithFaceFile(file:File):void {
			if(_file == null) {
				_file = file;
				load();
			} else {
				_file.deleteFile();
				_file = file;
				fadeOut();
			}
		}
		
		public function hasFile(file:File):Boolean {
			if(_file == null) {
				return false
			} else {
				return file.nativePath == _file.nativePath;
			}
		}
		
		private function load():void {
			var fileRequest:URLRequest = new URLRequest('file://' + _file.nativePath);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoadComplete, false, 0, true);
			_loader.load(fileRequest);
		}
		
		private function handleLoadComplete(event:Event):void {
			var image:DisplayObject = _loader.content;
			
			var oval:Sprite = new Sprite();
			var colors:Array = [0x000000, 0x000000];
			var alphas:Array = [1, 0];
			var ratios:Array = [0, 255];
			var matrix:Matrix = new Matrix();
			
			matrix.createGradientBox(image.width, image.height, 0, 0, 0);
			oval.graphics.beginGradientFill(GradientType.RADIAL,
				colors,
				alphas,
				ratios,
				matrix);
			oval.graphics.drawEllipse(0, 0, image.width, image.height);
			oval.graphics.endFill();
		
			_loader.cacheAsBitmap = true;
			oval.cacheAsBitmap = true;
			_loader.mask = oval;

			addChild(oval);
			addChild(_loader);
			
			fadeIn();
		}
		
		private function loadAndFadeIn():void {
			load();
			fadeIn();
		}
		
		private function fadeIn():void {
		trace("Fading in...");
			var myTimeline:TimelineLite = new TimelineLite({paused:true});
			var scaleX:Number = Math.random() + 1;
			var scaleY:Number = Math.random() + 1;
			myTimeline.append(TweenLite.to(this, Math.floor(5 + Math.random() * 10), {alpha:1, scaleX:scaleX, scaleY:scaleY, ease:Bounce.easeInOut}));
			myTimeline.append(TweenLite.to(this, Math.floor(5 + Math.random() * 10), {scaleX:2, scaleY:2, ease:Bounce.easeInOut}));
			myTimeline.play();
			
			if(!_bobbing) {
				bobRight();
				_bobbing = true;
			}			
		}
		
		private function fadeOut():void {
			TweenLite.to(this, Math.floor(2 + Math.random() * 2), {alpha:0, onComplete:loadAndFadeIn, ease:Bounce.easeInOut})
		}
		
		private function bobLeft():void {
			var fudge:uint = Math.floor(Math.random() * 2);
			TweenLite.to(this, _bobTime + fudge, {x:this.x - _bobDistance, onComplete:bobRight, ease:Quad.easeInOut});
		}
		
		private function bobRight():void {
			var fudge:uint = Math.floor(Math.random() * 2);
			TweenLite.to(this, _bobTime + fudge, {x:this.x + _bobDistance, onComplete:bobLeft, ease:Quad.easeInOut});
		}
	}
}