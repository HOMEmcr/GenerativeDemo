/**
 * HOME Generative Visuals - demonstration project.
 *  
 * A highly simplified example of the way in which our generative HOME visuals were created. This is the most basic possible 
 * demonstration of the idea, and is intended to simply show the flow as something human-readable: this code is currently 
 * far too inefficient to actually produce finished pieces! For an optimised open-source implementation please see the 
 * work of Roger Alsing, who inspired the project: rogeralsing.com/2008/12/07/genetic-programming-evolution-of-mona-lisa.
 * 
 * Requires OpenFL to run: https://github.com/openfl/openfl/wiki/Get-Started
 * For more info see the blog post here: http://blog.danhett.com/2013/07/generative-visuals-home.html
 * @author 	Dan Hett (hellodanhett@gmail.com)
 * @date	July 2013
 */

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.utils.Timer;

@:bitmap("assets/sample.gif") class Image extends BitmapData {} // imports the sample image

class Main extends Sprite 
{	
	private var targetImage:Bitmap;
	private var work:Sprite;
	private var diffBmp:BitmapData;
	private var temp:Sprite;
	private var closeness:Int = 0;
	private var diff:Int;
	private var baseColour:Int = 0x000000;
	private var startBtn:Sprite;
	private var stopBtn:Sprite;
	private var saveBtn:Sprite;
	private var stepTime:Float = 0.01; // time between each iteration, in seconds
	private var timer:Timer;
	
	public function new() 
	{	
		super();
		
		createSourceImage();
		createWorkingImage();
		createControls();
	}
	
	/**
	 * Creates the source material that we'll be working from.
	 */
	private function createSourceImage():Void 
	{
		targetImage = new Bitmap (new Image (0, 0));
		addChild (targetImage);
		
		targetImage.x = 20;
		targetImage.y = 20;
	}
	
	/**
	 * Creates the empty canvas that we'll be building our generative visuals into.
	 */
	private function createWorkingImage():Void
	{
		work = new Sprite();
		
		work.graphics.beginFill(baseColour);
		work.graphics.drawRect(0,0,400,400);
		work.graphics.endFill();
		
		work.x = 440;
		work.y = 20;
		addChild(work);
	}
	
	/**
	 * Adds a simple user interface so we can control the application.
	 */
	private function createControls():Void
	{
		// initialise the button sprites
		startBtn = new Sprite();
		stopBtn = new Sprite();
		saveBtn = new Sprite();
		
		var start:TextField = new TextField();
		start.text = "START";
		startBtn.x = 20;
		startBtn.y = 440;
		startBtn.addChild(start);
		addChild(startBtn);
		
		var stop:TextField = new TextField();
		stop.text = "STOP";
		stopBtn.x = 80;
		stopBtn.y = 440;
		stopBtn.addChild(stop);
		addChild(stopBtn);
		
		startBtn.mouseChildren = false;
		startBtn.buttonMode = true;
		startBtn.addEventListener(MouseEvent.CLICK, startGeneration);
		
		stopBtn.mouseChildren = false;
		stopBtn.buttonMode = true;
		stopBtn.addEventListener(MouseEvent.CLICK, stopGeneration);
		
		// also create the timer so it's ready to go when we start the application running:
		timer = new Timer(1000 * stepTime);
		timer.addEventListener(TimerEvent.TIMER, updateAttempt);
	}
	
	/**
	 * Begins/continues the generation cycle.
	 */
	private function startGeneration(e:MouseEvent):Void
	{
		timer.start();
	}
	
	/**
	 * Pauses the generation cycle if it is running.
	 */
	private function stopGeneration(e:MouseEvent):Void
	{
		timer.stop();
	}
	
	/**
	 * The actual update as called by the application timer that we're starting and stopping
	 */
	private function updateAttempt(e:TimerEvent):Void
	{
		placeRandomShape();
	}
	
	/**
	 * Draws a random test shape onto the work area
	 */
	private function placeRandomShape():Void
	{
		// give the shape a random colour and starting position
		var randColor:Int = Std.int(Math.random() * 0xFFFFFF);	
		var startX:Int = randRange(0, 400);
		var startY:Int = randRange(0, 400);
		
		// we draw the shape into a sprite so it can be removed if it's no closer
		temp = new Sprite();
		
		// draw the shape with random dimensions, making sure it closes properly
		temp.graphics.beginFill( randColor, 0.5 );
		temp.graphics.moveTo(startX, startY);
		temp.graphics.lineTo(randRange(0, 400), randRange(0, 400));
		temp.graphics.lineTo(randRange(0, 400), randRange(0, 400));
		temp.graphics.lineTo(startX, startY);
		temp.graphics.endFill();
		
		// add the shape so we can check if it's closer to the target
		work.addChild(temp);
		
		// if we're not closer, remove the shape again
		if(!isCloser())
			work.removeChild(temp);
	}
	
	/**
	 * Compares the target bitmap to the work bitmap to ascertain
	 * if we've gotten closer during the last iteration. 
	 */
	private function isCloser():Bool
	{
		diff = 0;
		
		// create comparison bitmapdatas, one of the target and one of the current working version
		var bmd1:BitmapData = new BitmapData(400,400);
		bmd1.draw(targetImage);
		var bmd2:BitmapData = new BitmapData(400,400);
		bmd2.draw(work);
		
		// loop through the pixels (very ineffecient but more human-readable)		
		for( i in 0...400 )
		{
			for( j in 0...400 )
			{
				// arbitrary threshold for demo purposes, not precise and very slow!!
				// In the real world this would be a much smarter comparison check.
				if(bmd1.getPixel(i,j) - bmd2.getPixel(i,j) < 1000000)
					diff++;
			}
		}
		
		// NOTE: a series of additional steps could be added at this point that would adjust existing shapes
		// if no new ones are getting closer, this can be seen in Alsing's work, linked at the top of this file.
		
		// IF we're closer, continue with the next shape (ideally the shape should be drawn directly
		// into the working bitmap, but for brevity it's just added in it's own sprite for now.)
		if(diff > closeness)
		{
			closeness = diff;
			return true;
		}		
		else
		{
			return false;
		}
	}
	
	private function randRange(start:Int, end:Int) : Int  
	{  
	   return Std.int(Math.floor(start +(Math.random() * (end - start))));  
	}
}