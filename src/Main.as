package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import starling.core.Starling;
	
	//[SWF(width="720", height="540", frameRate="60")]
	[SWF(width="1024", height="768", frameRate="60")]
	public class Main extends Sprite {
		
		private var __starling:Starling;
		
		public function Main() {
			
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			menu.customItems = [ new ContextMenuItem("© MEGAVISOR.com") ];
			
			this.contextMenu = menu;
			
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			this.start();
		}
		
		private function start():void {
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;
			
			this.__starling = new Starling(SequenceTest, this.stage);
			this.__starling.showStatsAt();
			this.__starling.antiAliasing = 0;
			this.__starling.start();
			
			this.stage.addEventListener(Event.RESIZE, this.stage_resizeHandler, false, int.MAX_VALUE, true);
			this.stage.addEventListener(Event.DEACTIVATE, this.stage_deactivateHandler);
		}
		
		private function stage_deactivateHandler(event:Event):void {
			this.__starling.stop();
			
			this.stage.addEventListener(Event.ACTIVATE, this.stage_activateHandler);
		}
		
		protected function stage_activateHandler(event:Event):void {
			this.__starling.start();
			
			this.stage.removeEventListener(Event.ACTIVATE, this.stage_activateHandler);
		}
		
		private function stage_resizeHandler(event:Event):void {
			this.__starling.stage.stageWidth = this.stage.stageWidth;
			this.__starling.stage.stageHeight = this.stage.stageHeight;
			
			try {
				this.__starling.viewPort.width = this.stage.stageWidth;
				this.__starling.viewPort.height = this.stage.stageHeight;
			} catch (error:Error) { }
		}
	}
}