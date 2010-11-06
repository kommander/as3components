package com.formzoo.demos.dashedline 
{
	import com.formzoo.utils.display.DashedLine;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
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
		private var allLines:Shape = new Shape();
		
		public function DashedLineDemo() 
		{
			addChild(currentLine);
			addChild(allLines);
			
			var format:TextFormat = new TextFormat('Helvetica, Arial, sans-serif', 10, 0x333333, true);
			
			var dashArrayLabel:TextField = new TextField();
			dashArrayLabel.defaultTextFormat = format;
			dashArrayLabel.text = 'dash format';
			dashArrayLabel.x = 10;
			dashArrayLabel.y = 5;
			dashArrayLabel.selectable = false;
			addChild(dashArrayLabel);
			
			format.size = 14
			dashArrayField.defaultTextFormat = format;
			dashArrayField.x = 10;
			dashArrayField.y = 20;
			dashArrayField.border = true;
			dashArrayField.borderColor = 0xCCCCCC;
			dashArrayField.background = true;
			dashArrayField.backgroundColor = 0xEFEFEF;
			dashArrayField.width = 100;
			dashArrayField.height = 20;
			dashArrayField.text = '5,10,2,5,10';
			dashArrayField.type = TextFieldType.INPUT;
			dashArrayField.addEventListener(Event.CHANGE, dashFieldChangeListener);
			dashArrayField.restrict = '0123456789,';
			
			addChild(dashArrayField);
			
			var resetField:TextField = new TextField();
			resetField.defaultTextFormat = format;
			resetField.text = 'ESC to reset';
			resetField.x = stage.stageWidth - resetField.textWidth - 10;
			resetField.y = stage.stageHeight - resetField.textHeight - 10;
			resetField.selectable = false;
			resetField.addEventListener(MouseEvent.MOUSE_OVER, resetFieldOverListener);
			resetField.addEventListener(MouseEvent.MOUSE_OUT, resetFieldOutListener);
			resetField.addEventListener(MouseEvent.CLICK, resetFieldClickListener);
			
			addChild(resetField);
			
			var gMatrix:Matrix = new Matrix();
			gMatrix.createGradientBox(stage.stageWidth, stage.stageHeight, Math.PI / 180 * 90);
			
			this.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xBBBBBEE], [1.0, 1.0], [128, 255], gMatrix);
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
			stage.addEventListener(MouseEvent.CLICK, mouseClickListener);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyListener);
			
			DashedLine.setDashes([5, 10, 2, 5, 10]);
			
			currentLine.graphics.lineStyle(3, lineColor, 1, false, LineScaleMode.NORMAL, null, JointStyle.ROUND);
			DashedLine.moveTo(currentLine.graphics, stage.stageWidth / 2 - 50, stage.stageHeight / 2 + 50);
			DashedLine.lineTo(currentLine.graphics, stage.stageWidth / 2 + 50, stage.stageHeight / 2 + 50);
			DashedLine.lineTo(currentLine.graphics, stage.stageWidth / 2, stage.stageHeight / 2 - 50);
			DashedLine.lineTo(currentLine.graphics, stage.stageWidth / 2 - 50, stage.stageHeight / 2 + 50);
			
		}
		
		private function resetFieldOverListener(evt:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
		}
		
		private function resetFieldOutListener(evt:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		private function resetFieldClickListener(evt:MouseEvent):void
		{
			evt.stopPropagation();
			reset();
		}
		
		private function keyListener(evt:KeyboardEvent):void
		{
			if (evt.keyCode == Keyboard.ESCAPE)
				reset();
		}
		
		private function dashFieldChangeListener(evt:Event):void
		{
			DashedLine.setDashes(dashArrayField.text.split(','));
		}
		
		private function reset():void
		{
			fromX = -1;
			fromY = -1;
			allLines.graphics.clear();
			currentLine.graphics.clear();
			lineColor = 0x334455;
		}
		
		private function mouseMoveListener(evt:MouseEvent):void
		{
			if (fromX > -1 && fromY > -1)
			{
				currentLine.graphics.clear();
				currentLine.graphics.lineStyle(3, lineColor, 1, false, LineScaleMode.NORMAL, null, JointStyle.ROUND);
				DashedLine.moveTo(currentLine.graphics, fromX, fromY);
				DashedLine.lineTo(currentLine.graphics, stage.mouseX, stage.mouseY);
			}
		}
		
		private function mouseClickListener(evt:MouseEvent):void
		{
			if (fromX > -1 && fromY > -1)
			{
				allLines.graphics.lineStyle(3, lineColor, 1, false, LineScaleMode.NORMAL, null, JointStyle.ROUND);
				DashedLine.moveTo(allLines.graphics, fromX, fromY);
				DashedLine.lineTo(allLines.graphics, stage.mouseX, stage.mouseY);
			}
			fromX = stage.mouseX;
			fromY = stage.mouseY;
			lineColor = lineColor * 1.1;
		}
		
	}

}