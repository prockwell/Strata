/**
 * Created with IntelliJ IDEA.
 * User: peterrockwell
 * Date: 1/25/2014
 * Time: 11:20 PM
 */
package
{
	public class Utils
	{
		public static function convertRange(originalStart:Number,
		                                    originalEnd:Number,
		                                    newStart:Number,
		                                    newEnd:Number,
		                                    value:Number):Number
		{
			var originalRange:Number = originalEnd - originalStart;
			var newRange:Number = newEnd - newStart;
			var ratio:Number = newRange / originalRange;
			var newValue:Number = value * ratio;
			var finalValue:Number = newValue + newStart;
			return finalValue;
		}

		public static function distanceTwoPoints(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x1-x2;
			var dy:Number = y1-y2;
			return Math.sqrt(dx * dx + dy * dy);
		}

	}
}
