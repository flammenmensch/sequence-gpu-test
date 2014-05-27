package {
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Strong;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.data.LoaderMaxVars;
	import com.greensock.loading.display.ContentDisplay;
	import com.greensock.plugins.ThrowPropsPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import feathers.themes.MetalWorksMobileTheme;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.BlurFilter;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	public class SequenceTest extends Sprite {
		
		[Embed(source="/../assets/data/images.json", mimeType="application/octet-stream")]
		private static const DATA:Class;
		
		private var __imageDisplay:Image;
		
		private var __dataSource:Object;
		
		private var __queue:LoaderMax;
		
		private var __currentIndex:uint;
		
		private const __tweenObject:Object = {
			index: 0
		};
		
		private var __t1:Number;
		private var __t2:Number;
		
		private var __x1:Number;
		private var __x2:Number;
		
		private var __textureCache:Dictionary = new Dictionary(false);
		
		public function SequenceTest() {
			super();
			
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, this.addedToStageHandler);
		}
		
		private function addedToStageHandler(event:starling.events.Event):void {
			this.removeEventListener(starling.events.Event.ADDED_TO_STAGE, this.addedToStageHandler);
			
			new MetalWorksMobileTheme();
			
			this.__dataSource = this.decodeDataSource();
			
			var emptyTexture:Texture = Texture.fromColor(this.stage.stageWidth, this.stage.stageHeight);
			
			this.__imageDisplay = new Image(emptyTexture);
			this.__imageDisplay.smoothing = TextureSmoothing.NONE;
			this.__imageDisplay.width = this.stage.stageWidth;
			this.__imageDisplay.height = this.stage.stageHeight;
			this.addChild(this.__imageDisplay);
			
			TweenPlugin.activate([ThrowPropsPlugin]);
					
			this.stage.addEventListener(TouchEvent.TOUCH, this.stage_touchHandler);
			
			var settings:LoaderMaxVars = new LoaderMaxVars();
			settings
				.autoLoad(false)
				.auditSize(true)
				.maxConnections(10)
				.onComplete(this.loader_completeHandler);
			
			this.__queue = new LoaderMax(settings);	
			
			for (var i:uint = 0, n:uint = this.__dataSource.images.length; i < n; i++) {
				this.__queue.append(
					new ImageLoader(
						"../assets/images/" + this.__dataSource.images[i].src,
						{ name: this.__dataSource.images[i].src }
					)
				);
			}
			
			this.__queue.load();
		}
		
		private function decodeDataSource():Object {
			var bytes:ByteArray = new DATA as ByteArray;
			
			var str:String = bytes.readUTFBytes(bytes.length);
			
			var obj:Object = JSON.parse(str); 
			
			return obj;
		}
		
		private function stage_touchHandler(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this.__imageDisplay);
			
			if (touch === null) {
				return;
			}
			
			var touchPoint:Point = touch.getLocation(this.__imageDisplay);
			
			switch (touch.phase) {
				case TouchPhase.BEGAN:
					this.imageDisplay_touchBeganHandler(touchPoint);
					break;
				case TouchPhase.MOVED:
					this.imageDisplay_touchMovedHandler(touchPoint);
					break;
				case TouchPhase.ENDED:
					this.imageDisplay_touchEndedHandler(touchPoint);
					break;
				default:
					break;
			}
		}
		
		private function imageDisplay_touchBeganHandler(point:Point):void {
			trace("mouse down...");
			TweenMax.killTweensOf(this.__tweenObject);
			
			this.__t1 = this.__t2 = getTimer();
			
			this.__x1 = this.__x2 = point.x;
		}
		
		private function imageDisplay_touchMovedHandler(point:Point):void {
			trace("mouse move...");
			
			this.__x2 = this.__x1;
			this.__x1 = point.x;
			
			var diff:int = Math.round((this.__x1 - this.__x2) * .3);
			
			if (diff !== 0) {
				var newIndex:int = this.adjustIndex(this.__currentIndex + diff);
				
				if (this.__currentIndex !== newIndex) {
					this.__currentIndex = newIndex;
					this.updateContentByIndex(this.__currentIndex);
				}
			}
			
			this.__t1 = getTimer();
		}
		
		private function imageDisplay_touchEndedHandler(point:Point):void {
			var time:Number = (getTimer() - this.__t2) * 0.001;
			
			var velocity:Number = (point.x - this.__x2) / time;
			
			if (Math.abs(velocity) < 5) {
				return;
			}
			
			ThrowPropsPlugin.to(this.__tweenObject, {
				onUpdate: this.tween_updateHandler,
				onComplete: this.tween_completeHandler,
				ease: Strong.easeOut,
				throwProps: {
					index: {
						velocity: velocity,
						resistance: 1000
					}
				}
			}, 10, 2, 1);
		}
		
		private function tween_updateHandler():void {
			var newIndex:int = this.adjustIndex(Math.ceil(this.__tweenObject.index));
			
			if (this.__currentIndex !== newIndex) {
				this.__currentIndex = newIndex;
				this.updateContentByIndex(newIndex);
			}
		}
		
		private function tween_completeHandler():void {
			trace("tween completed");
			
			TweenMax.killTweensOf(this.__tweenObject);
		}
		
		private function loader_completeHandler(event:LoaderEvent):void {
			this.updateContentByIndex(0);
		}
		
		private function adjustIndex(value:int):uint {
			var length:uint = this.__dataSource.images.length;
			
			if (value < 0) {
				return length + value % length;
			}
			
			if (value >= length) {
				return value %= length;
			}
			
			return value;
		}
		
		private function updateContentByIndex(index:int):void {
			var startRender:int = getTimer();
			
			var imageObject:Object = this.__dataSource.images[index];
			var imageLoader:ImageLoader = this.__queue.getLoader(imageObject.src) as ImageLoader;
			
			var contentDisplay:ContentDisplay = imageLoader.content as ContentDisplay;
			
			if (contentDisplay === null) {
				return;
			}
			
			var matrix:Matrix = new Matrix();
			
			var scaleH:Number = this.stage.stageHeight / contentDisplay.height;
			var scaleW:Number = this.stage.stageWidth / contentDisplay.width;
			
			matrix.scale(scaleW, scaleH);
			
			var bitmapData:BitmapData = new BitmapData(this.stage.stageWidth, this.stage.stageHeight, false, 0x000000);
			bitmapData.draw(contentDisplay, matrix, null, null, null, true);

			var texture:Texture = Texture.fromBitmapData(bitmapData, false, true, 1);
			
			/*var bitmap:Bitmap = imageLoader.rawContent as Bitmap;
			
			var scaleH:Number = this.stage.stageHeight / bitmap.height;
			var scaleW:Number = this.stage.stageWidth / bitmap.width;
			
			bitmap.smoothing = true;
			bitmap.scaleX = scaleW;
			bitmap.scaleY = scaleH;
			
			var texture:Texture = Texture.fromBitmap(bitmap, false, true);*/
			
			this.__imageDisplay.texture.dispose();
			this.__imageDisplay.texture = texture;
			
			var endRender:int = getTimer();
			
			trace("render time", endRender - startRender);
		}
		
		/*private function updateContentByIndex(index:int):void {
			var imageObject:Object = this.__dataSource.images[index];
			
			if (!this.__textureCache[imageObject.src]) {
				var imageLoader:ImageLoader = this.__queue.getLoader(imageObject.src) as ImageLoader;
				
				var contentDisplay:ContentDisplay = imageLoader.content as ContentDisplay;
				
				if (contentDisplay === null) {
					return;
				}
				
				var matrix:Matrix = new Matrix();
				
				var scaleH:Number = this.stage.stageHeight / contentDisplay.height;
				var scaleW:Number = this.stage.stageWidth / contentDisplay.width;
				
				matrix.scale(scaleW, scaleH);
				
				var bitmapData:BitmapData = new BitmapData(this.stage.stageWidth, this.stage.stageHeight, false, 0x000000);
				bitmapData.draw(contentDisplay, matrix);
				
				this.__textureCache[imageObject.src] = bitmapData;
			}
			
			var texture:Texture = Texture.fromBitmapData(this.__textureCache[imageObject.src] as BitmapData, false, true);
			
			this.__queue.remove(imageLoader);
			
			this.__imageDisplay.texture.dispose();
			this.__imageDisplay.texture = texture;
		}*/
	}
}