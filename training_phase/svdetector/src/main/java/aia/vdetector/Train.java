package aia.vdetector;

import java.io.FileReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;

import aia.vdetector.io.DetectorsFile;
import aia.vdetector.io.PointsFile;
import aia.vdetector.io.ResultsFile;
import aia.vdetector.test.DetectorJob;
import aia.vdetector.test.SimpleMain;
import aia.vdetector.test.DetectorJob.Dataset;

public class Train
{
	static final Logger log = Logger.getLogger(Train.class);
	static String agentName = null;
	static String trainFilename = null;
	static String fileName = null;
	static String folderIn = null;
	static String vdFilename = "vdetector_test.txt";
	static String evalFilename;
	static String testFilename;
	static String outputFilename = "evaluated_test.txt";
	static String thresholdsFile;
	static String configFilename;
	static String trainConfigsFile;
	static List<Double> thresholds;
	
	

	public static void main(String[] args) throws Exception
	{

		BasicConfigurator.configure();
		
		if (args != null && args.length == 1)
		{
			trainConfigsFile = args[0];
		} else
		{
			throw new RuntimeException("Bad parameters. Properties file required.");
		}

		Properties configFile = new Properties();
		configFile.load(new FileReader(trainConfigsFile));
		TrainConfiguration trainConfigs = new TrainConfiguration(configFile);

		// Dataset info ===================================
		DatasetS dataset = trainConfigs.getDataset();

		trainFilename = dataset.getTrainFilename();
		testFilename = dataset.getTestFilename();
		evalFilename = dataset.getEvalFilename();
		configFilename = dataset.getConfigFilename();

		// Configuration info =============================
		List<DetectorGeneratorConfiguration> configs = trainConfigs.getConfigurations();
		int loopsNum = trainConfigs.getLoopsNum();
		boolean testData = trainConfigs.getTestData();
		
		for (int k = 0; k < configs.size(); k++)
		{
			DetectorGeneratorConfiguration config = configs.get(k);
			double thr = config.getThreshold();
			System.out.println("===================================================");
			System.out.println("    NEW threshold ---------------------------------");
			System.out.println("    threshold = " + thr);
			System.out.println("===================================================");

			Results results = new Results();
			results.setConfig(config);
			results.setLoopsNum(loopsNum);
			ResultsFile filetestFile = new ResultsFile(configFilename);
			log.info("ResultsFile fileName :" + filetestFile.getFileName());
			log.info("ResultsFile fileNameId :" + filetestFile.getFileNameId());
			log.info("ResultsFile getFileNameParent :" + filetestFile.getFileNameParent());
			log.info("ResultsFile getFileNameResults :" + filetestFile.getFilePathResults());
			for (int i = 0; i < loopsNum; i++)
			{
				train(config, i, filetestFile.getFilePathResults());
				if (testData) {
					evaluate(i, filetestFile.getFilePathResults());
					check(results);
				}
			}
			filetestFile.write(results);
		}

	}

	private static void train(DetectorGeneratorConfiguration config, int i, String filePathResults)
			throws IOException, DetectorException
	{
		List<Point> trainingPoints = new PointsFile(trainFilename).read();

		VDetector vd = new VDetector(config);
		vd.train(trainingPoints);

		DetectorsFile df = new DetectorsFile(filePathResults + "\\" + vdFilename + "_" + i + ".vd");
		df.write(vd.getDetectors());
	}

	private static void evaluate(int i, String filePathResults) throws IOException
	{
		DetectorsFile df = new DetectorsFile(filePathResults + "\\" + vdFilename + "_" + i + ".vd");
		VDetector vd = new VDetector(df.read());

		List<Point> evaluationPoints = new PointsFile(evalFilename).read();
		// Not needed in fact, but we ensure that points that are going to be
		// evaluated do not have a label
		for (Point p : evaluationPoints)
			p.setLabel(Point.Label.NONE);
		vd.detect(evaluationPoints);
		int counter = 0;
		for (Point p : evaluationPoints)
			if (p.getLabel() == Point.Label.ABNORMAL)
			{
				counter++;
			}
		System.out.println("ABNORMAL " + counter);
		new PointsFile(filePathResults + "\\" + outputFilename + "_" + i + ".vd").write(evaluationPoints);
		new PointsFile(outputFilename).write(evaluationPoints);
	}

	private static void check(Results results) throws IOException
	{
		List<Point> evaluatedPoints = new PointsFile(outputFilename).read();
		List<Point> testPoints = new PointsFile(testFilename).read();
		results.setPointsNum(evaluatedPoints.size());
		int bad = 0;
		int truePositive = 0;
		int falsePositive = 0;
		int trueNegative = 0;
		int falseNegative = 0;
		for (int k = 0; k < evaluatedPoints.size(); k++)
		{
			Point.Label l1 = evaluatedPoints.get(k).getLabel();
			Point.Label l2 = testPoints.get(k).getLabel();
			if (!l1.equals(l2))
			{
				bad++;
				if (l2.equals(Point.Label.ABNORMAL))
				{
					falseNegative++;
				} else
				{
					falsePositive++;
				}
			} else
			{
				if (l2.equals(Point.Label.ABNORMAL))
				{
					truePositive++;
				} else
				{
					trueNegative++;
				}
			}
		}
		log.info("evaluated points       " + evaluatedPoints.size());
		log.info("misclassified          " + bad);
		double badRate = 1.0 * bad / evaluatedPoints.size();
		log.info("misclassification rate " + badRate);
		log.info("false positive (false alarms) " + falsePositive);
		double falsePositiveRate = 1.0 * falsePositive / (falsePositive + trueNegative);
		log.info("true negative " + trueNegative);
		log.info("false positive rate " + falsePositiveRate);
		log.info("true positive (detections) " + truePositive);
		double truePositiveRate = 1.0 * truePositive / (truePositive + falseNegative);
		log.info("true positive rate " + truePositiveRate);

		ArrayList<Double> resultsArrayPart = new ArrayList<Double>();
		resultsArrayPart.add((double) truePositive);
		resultsArrayPart.add((double) falsePositive);

		resultsArrayPart.add((double) truePositiveRate);
		resultsArrayPart.add((double) falsePositiveRate);

		results.addResultsArray(resultsArrayPart);

	}

}
