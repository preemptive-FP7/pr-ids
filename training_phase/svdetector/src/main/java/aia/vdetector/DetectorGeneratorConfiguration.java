package aia.vdetector;

public class DetectorGeneratorConfiguration
{
	public boolean isHypothesisTesting()
	{
		return hypothesisTesting;
	}

	public void setHypothesisTesting(boolean hypothesisTesting)
	{
		this.hypothesisTesting = hypothesisTesting;
	}

	public int getMaxDetectors()
	{
		return maxDetectors;
	}

	public void setMaxDetectors(int maxDetectors)
	{
		this.maxDetectors = maxDetectors;
	}

	public double getThreshold()
	{
		return threshold;
	}

	public void setThreshold(double threshold)
	{
		this.threshold = threshold;
	}

	public double getCoverage()
	{
		return coverage;
	}

	public void setCoverage(double coverage)
	{
		this.coverage = coverage;
	}

	public int getMaxSampling()
	{
		return DEFAULT_MAX_SAMPLING;
	}

	public int getCandidateMaxTries()
	{
		return DEFAULT_MAX_TRIES;
	}

	// Hypothesis

	public double getAlpha()
	{
		return DEFAULT_ALPHA;
	}

	private boolean hypothesisTesting;
	private int maxDetectors;
	private double threshold;
	private double coverage;


	private static final int DEFAULT_MAX_TRIES = 1000;
	private static final int DEFAULT_MAX_SAMPLING = 1000000;
	private static final double DEFAULT_ALPHA = 0.9;
}
