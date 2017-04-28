package aia.vdetector;

public class DistanceMinkowski implements Distance
{
	public DistanceMinkowski(double norm)
	{
		assert (norm > 1.0);
		this.norm = norm;
	}

	public String getName()
	{
		return "Minkowski distance of order " + norm + "(" + norm + "-norm distance)";
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
			double dk = Math.abs(x1[k] - x2[k]);
			d += Math.pow(dk, norm);
		}
		d = Math.pow(d, 1.0 / norm);
		return d;
	}

	private final double	norm;
}
