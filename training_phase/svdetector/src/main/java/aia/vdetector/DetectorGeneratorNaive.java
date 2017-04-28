package aia.vdetector;

import java.util.ArrayList;
import java.util.List;

public class DetectorGeneratorNaive extends DetectorGenerator
{
	public DetectorGeneratorNaive(DetectorGeneratorConfiguration config)
	{
		super(config);
	}

	@Override
	public List<Detector> generate(List<Point> training) throws DetectorException
	{
		int maxDetectors = config.getMaxDetectors();
		int maxInvalid = (int) Math.ceil(1.0 / (1.0 - config.getCoverage()));
		int maxSampling = config.getMaxSampling();

		int countValid = 0;
		int countInvalid = 0;
		int countCandidates = 0;
		List<Detector> detectors = new ArrayList<Detector>(maxDetectors);
		do
		{
			Detector detector = candidate(training);
			countCandidates++;

			// log.debug("candidate " + countCandidates);
			if (!Detector.detects(detectors, detector.getCenter()))
			{
				countValid++;
				// log.debug("valid candidate added, " + j);
				detector.setName("naive." + countValid);
				detectors.add(detector);
				countInvalid = 0;
			}
			else
			{
				countInvalid++;
			}
		}
		while ((countInvalid < maxInvalid) && (countValid < maxDetectors) && (countCandidates < maxSampling));
		// if (countCandidates == maxSampling) log.info("I'm tired of this. I sampled " + maxSampling + " times!");
		// log.info("Total number of detectors is " + detectors.size());

		return detectors;
	}
}
