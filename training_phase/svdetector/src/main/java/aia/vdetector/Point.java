package aia.vdetector;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Collection;
import java.util.Locale;

public class Point
{
	public static int PRECISION = 7;
	static double PRECISION_FACTOR = Math.pow(10, PRECISION);
	public static DecimalFormat formatter;

	public static enum Label
	{
		NORMAL, ABNORMAL, NONE;
	};

	public Point(String id, Label label, double[] x)
	{
		this.id = id;
		this.label = label;
		int dimension = x.length;
		this.x = new double[dimension];
		for (int k = 0; k < dimension; k++)
			this.x[k] = x[k];
		initDistance();
	}

	private Point(String id, Label label, int dimension)
	{
		this.id = id;
		this.label = label;
		this.x = new double[dimension];
		initDistance();
	}

	public static Point random(int dimension)
	{
		String label = "random." + (counter++);
		Point p = new Point(label, Label.NONE, dimension);
		for (int k = 0; k < dimension; k++)
			p.x[k] = Math.random();
		return p;
	}

	public void setDistance(Distance distance)
	{
		distanceFunction = distance;
	}

	public Distance getDistance()
	{
		return distanceFunction;
	}

	public String getId()
	{
		return id;
	}

	public Label getLabel()
	{
		return label;
	}

	public void setLabel(Label label)
	{
		this.label = label;
	}

	public double[] getComponents()
	{
		return this.x;
	}

	public int getDimension()
	{
		return this.x.length;
	}

	public double distance(Point other)
	{
		// TODO use a constant for rounding precision, use same constant to
		// properly write center points and radius in detector files
		double d = distanceFunction.distance(this, other);
		return Math.round(d * PRECISION_FACTOR) / PRECISION_FACTOR;
	}

	public Double nearestDistance(Collection<Point> others)
	{
		double dmin = Double.MAX_VALUE;
		for (Point other : others)
		{
			double d = distance(other);
			if (d < dmin)
				dmin = d;
		}
		return dmin;
	}

	public String toString()
	{
		StringBuffer s = new StringBuffer("( ");
		for (double xk : x)
			s.append(xk + " ");
		s.append(")");
		return s.toString();
	}

	private void initDistance()
	{
		distanceFunction = DistanceEuclidean2.instance();
	}

	private final String id;
	private final double[] x;
	private Label label;
	private Distance distanceFunction;

	private static int counter;

	public final static String printformat(double number){
		return String.format("%."+ String.valueOf(PRECISION + 2) + "f", number);
	}
	

	static
	{
		Locale currentLocale = Locale.getDefault();
		DecimalFormatSymbols otherSymbols = new DecimalFormatSymbols(currentLocale);
		otherSymbols.setDecimalSeparator('.');
		otherSymbols.setGroupingSeparator(','); 
//		DecimalFormat df = new DecimalFormat(formatString, otherSymbols);
		String sformat = "#0.";
		for (int k = 0; k < PRECISION + 2; k++)
			sformat += "0";
//		formatter = new DecimalFormat(sformat);
		formatter = new DecimalFormat(sformat, otherSymbols);
	}
}
