package {	import flash.display.MovieClip;	import flash.display.Sprite;	/**
	 * @author Colin
	 */
	public class Main extends MovieClip{		private var arySprite:Array=[];		public function Main(){			this.stage.align = "TL";			for(var i:int=0;i<14;i++){				arySprite[i]=new Sprite();				arySprite[i].x = i%4*160;				arySprite[i].y = Math.floor(i/4)*200;				this.addChild(arySprite[i]);			}			new TestSample(arySprite[0]);			new TestSample2(arySprite[1]);			new TestSample3(arySprite[2]);			new TestSample4(arySprite[3]);			new TestSample5(arySprite[4]);			new TestSample6(arySprite[5]);			new TestSample7(arySprite[6]);			new TestSample8(arySprite[7]);			new TestSample9(arySprite[8]);			new TestSample10(arySprite[9]);			new TestSample11(arySprite[10]);			new TestSample13(arySprite[11]);			new TestSample12(arySprite[12]);		}	}}