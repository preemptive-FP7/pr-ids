package aia.vdetector;

import java.util.List;

public abstract class DetectorGenerator
{
	public DetectorGenerator(DetectorGeneratorConfiguration config)
	{
		this.config = config;
	}

	public static DetectorGenerator newInstance(DetectorGeneratorConfiguration config)
	{
		// Factory method, determine which DetectorGenerator to use
		return config.isHypothesisTesting() ? new DetectorGeneratorHypothesis(config) : new DetectorGeneratorNaive(config);
	}

	public abstract List<Detector> generate(List<Point> training) throws DetectorException;

	protected Detector candidate(List<Point> training) throws DetectorException
	{
		assert (training != null);
		assert (training.size() != 0);
		int dimension = training.get(0).getDimension();

		for (int k = 0; k < config.getCandidateMaxTries(); k++)
		{
			Point p = Point.random(dimension);
			double d = p.nearestDistance(training);
			// log.debug("try random point with nearest distance to training set = " + distance + ", threshold = " + this.setting.getThreshold());
			if (d >= config.getThreshold()) return new Detector(p, d);
		}

		throw new DetectorException("Too much self region. Threshold = " + config.getThreshold() + "; Tries = " + config.getCandidateMaxTries());
	}

	protected final DetectorGeneratorConfiguration	config;
}
