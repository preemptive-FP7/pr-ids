package aia.vdetector;

import java.util.List;

public class VDetector
{
	public VDetector(DetectorGeneratorConfiguration config)
	{
		this.config = config;
	}

	public VDetector(List<Detector> detectors)
	{
		this.config = null;
		this.detectors = detectors;
	}

	public void train(List<Point> training) throws DetectorException
	{
		DetectorGenerator g = DetectorGenerator.newInstance(config);
		detectors = g.generate(training);
	}

	public List<Detector> getDetectors()
	{
		return detectors;
	}

	public void detect(List<Point> points)
	{
		for (Point p : points)
		{
			boolean detected = Detector.detects(detectors, p);
			Point.Label label = (detected ? Point.Label.ABNORMAL : Point.Label.NORMAL);
			p.setLabel(label);
		}
	}

	private final DetectorGeneratorConfiguration	config;
	private List<Detector>							detectors;
}
