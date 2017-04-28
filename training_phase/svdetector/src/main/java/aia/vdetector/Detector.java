package aia.vdetector;

import java.util.Collection;

public class Detector
{
	public Detector(Point center, double radius)
	{
		this.center = center;
		this.radius = radius;
	}

	public boolean detects(Point p)
	{
		return this.center.distance(p) < this.radius;
	}

	public static boolean detects(Collection<Detector> detectors, Point p)
	{
		if (detectors.size() == 0) return false;
		for (Detector detector : detectors)
		{
			if (detector.detects(p))
			{
				/*
				System.out.println("point " + p.getId() + " detected by " + detector.getName());
				System.out.println("    point    = " + p);
				System.out.println("    vdcenter = " + detector.center);
				System.out.format( "    distance = %.15f%n", detector.center.distance(p));
				System.out.format( "    vdradius = %.15f%n", detector.radius);
				*/
				return true;
			}
		}
		return false;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getName()
	{
		return name;
	}

	public Point getCenter()
	{
		return this.center;
	}

	public double getRadius()
	{
		return this.radius;
	}

	public String toString()
	{
		return center + ":" + radius;
	}

	private String			name;
	private final Point		center;
	private final double	radius;
}
