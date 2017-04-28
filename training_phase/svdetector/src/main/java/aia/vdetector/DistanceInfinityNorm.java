package aia.vdetector;

public class DistanceInfinityNorm implements Distance
{
	public String getName()
	{
		return "InfinityNorm";
	}

	@Override
	public double distance(Point p1, Point p2)
	{
		assert (p1.getDimension() == p2.getDimension());
		double dmax = 0.0;
		double[] x1 = p1.getComponents();
		double[] x2 = p2.getComponents();
		for (int k = 0; k < p1.getDimension(); k++)
		{
			double dk = Math.abs(x1[k] - x2[k]);
			if (dk > dmax) dmax = dk;
		}
		return dmax;
	}

	public static Distance instance()
	{
		return DISTANCE_INFINITY_NORM;
	}

	private static final Distance	DISTANCE_INFINITY_NORM	= new DistanceInfinityNorm();
}
