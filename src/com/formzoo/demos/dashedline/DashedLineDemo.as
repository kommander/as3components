package com.formzoo.demos.dashedline 
{
	import com.formzoo.utils.display.DashedLine;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	
	/**
	 * A little demonstration of the DashedLine util
	 * 
	 * @author Sebastian Herrlinger
	 */
	public class DashedLineDemo extends Sprite
	{
		private var dashArrayField:TextField = new TextField();
		private var lineColor:uint = 0x334455;
		private var fromX:Number = -1;
		private var fromY:Number = -1;
		private var currentLine:Shape = new Shape();
		
		public function DashedLineDemo() 
		{
			addChild(currentLine);
			
			dashArrayField.x = 10;
			dashArrayField.y = 10;
			dashArrayField.border = true;
			dashArrayField.borderColor = 0xCCCCCC;
			dashArrayField.background = true;
			dashArrayField.backgroundColor = 0xEEEEEF;
			dashArrayField.width = 100;
			dashArrayField.height = 20;
			dashArrayField.text = '5,8,3,8';
			dashArrayField.type = TextFieldType.INPUT;
			dashArrayField.addEventListener(Event.CHANGE, dashFieldChangeListener);
			dashArrayField.restrict = '0123456789,';
			
			addChild(dashArrayField);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
			stage.addEventListener(MouseEvent.CLICK, mouseClickListener);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyListener);
			
			DashedLine.setLengths([5, 10, 2, 5, 10]);
		}
		
		private function keyListener(evt:KeyboardEvent):void
		{
			if (evt.keyCode == Keyboard.ESCAPE)
				this.graphics.clear();
		}
		
		private function dashFieldChangeListener(evt:Event):void
		{
			DashedLine.setLengths(dashArrayField.text.split(','));
		}
		
		private function mouseMoveListener(evt:MouseEvent):void
		{
			if (fromX > -1 && fromY > -1)
			{
				currentLine.graphics.clear();
				currentLine.graphics.lineStyle(3, lineColor, 1, false, LineScaleMode.NORMAL, null, JointStyle.ROUND);
				DashedLine.moveTo(currentLine.graphics, fromX, fromY);
				DashedLine.lineTo(currentLine.graphics, evt.localX, evt.localY);
			}
		}
		
		private function mouseClickListener(evt:MouseEvent):void
		{
			if (fromX > -1 && fromY > -1)
			{
				this.graphics.lineStyle(3, lineColor, 1, false, LineScaleMode.NORMAL, null, JointStyle.ROUND);
				DashedLine.moveTo(this.graphics, fromX, fromY);
				DashedLine.lineTo(this.graphics, evt.localX, evt.localY);
			}
			fromX = evt.localX;
			fromY = evt.localY;
			lineColor = lineColor * 1.1;
		}
		
	}

}