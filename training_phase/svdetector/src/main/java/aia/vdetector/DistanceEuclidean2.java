package aia.vdetector;

public class DistanceEuclidean2 implements Distance
{
	public String getName()
	{
		return "Euclidean2";
	}

	@Override
	public double distance(Point p1, Point p2)
	{
		assert (p1.getDimension() == p2.getDimension());
		double d = 0.0;
		double[] x1 = p1.getComponents();
		double[] x2 = p2.getComponents();
		for (int k = 0; k < p1.getDimension(); k++)
		{
			double dk = x1[k] - x2[k];
			d += dk * dk;
		}
		return d;
	}

	public static Distance instance()
	{
		return DISTANCE_EUCLIDEAN2;
	}

	private static final Distance	DISTANCE_EUCLIDEAN2	= new DistanceEuclidean2();
}
