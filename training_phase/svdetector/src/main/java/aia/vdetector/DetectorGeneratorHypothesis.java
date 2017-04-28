package aia.vdetector;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.math3.distribution.NormalDistribution;

public class DetectorGeneratorHypothesis extends DetectorGenerator
{
	public DetectorGeneratorHypothesis(DetectorGeneratorConfiguration config)
	{
		super(config);
	}

	@Override
	public List<Detector> generate(List<Point> training) throws DetectorException
	{
		int maxSampling = config.getMaxSampling();
		int maxDetectors = config.getMaxDetectors();

		List<Detector> detectors1 = new ArrayList<Detector>(maxDetectors);
		List<Detector> detectors2 = new ArrayList<Detector>(maxDetectors);
		DetectorGenerationState state = new DetectorGenerationState(config);
		int countCandidates = 0;
		int countValid = 0;

		do
		{
			Detector localDetector = candidate(training);
			state.N++;

			if (Detector.detects(detectors2, localDetector.getCenter()))
			{
				state.x++;
				state.z += state.term1;
				if (state.z > state.zalpha) break;
			}
			else
			{
				localDetector.setName("hypothesis." + countValid);
				detectors1.add(localDetector);
				countValid++;
			}
			if (state.N == state.n)
			{
				detectors2.addAll(detectors1);
				// log.debug("A group of " + detectors1.size() + " detectors have been generated.");
				// log.debug("Sampled points N = " + state.N + ", covered points x = " + this.x);
				detectors1.clear();
				state.N = 0;
				state.x = 0;
				state.z = state.term2;
			}
			countCandidates++;
		}
		while (countCandidates < maxSampling);
		// if (countCandidates < maxSampling) log.info("I'm tired of this. I sampled " + maxSampling + " times!");
		// log.info("Total number of detectors is " + detectors2.size());
		return detectors2;
	}

	private static class DetectorGenerationState
	{
		DetectorGenerationState(DetectorGeneratorConfiguration config) throws DetectorException
		{
			N = 0;
			x = 0;
			double d1 = 1.0 - 5.0 / config.getMaxDetectors();
			if (config.getCoverage() > d1) throw new DetectorException("Too large coverage expected. Coverage=" + config.getCoverage() + ", maxCoverage = " + d1);
			double d2 = config.getCoverage();
			double d3 = 1.0 - d2;
			n = ((int) Math.ceil(Math.max(5.0 / d2, 5.0 / d3)));
			zalpha = new NormalDistribution().inverseCumulativeProbability(1.0 - config.getAlpha());
			term1 = (1.0D / Math.sqrt(n * d2 * d3));
			term2 = (-Math.sqrt(n * d2 / d3));
			z = term2;
		}

		int		N		= 0;

		// TODO we should be able to generate only one more detector given a state (to be used for demo)
		// See code in tryToGenerateOneDetector in original DetectorGenerator
		int		x		= 0;

		int		n		= 0;
		double	zalpha	= 0.0;
		double	term1	= 0.0;
		double	term2	= 0.0;
		double	z		= 0.0;
	}
}
