package
{
	import Main.StartMc;

	import flash.display.Sprite;

	[SWF(width="1280", height="720")]
	public class Strata extends Sprite
	{
	    public function Strata()
	    {
	        var startMc:StartMc = new StartMc();
		    addChild(startMc);
	    }
	}
}
