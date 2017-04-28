package aia.vdetector;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

public class TrainConfiguration
{

	public TrainConfiguration(Properties configFile) throws DetectorException
	{
		configure(configFile);
	}

	void configure(Properties jconfig) throws DetectorException
	{
		// Dataset

		String folderIn = gets(jconfig, "folderIn", null);
		String fileName = gets(jconfig, "fileName", null);
		String agentName = gets(jconfig, "agentName", null);

		dataset = new DatasetS(folderIn, fileName, agentName);

		// Configurations

		loopsNum = geti(jconfig, "loopsNum", 10);
		List<Double> thresholds = getdlist(jconfig, "thresholds", Arrays.asList(0.001, 0.005, 0.01));
		List<Double> coverages = getdlist(jconfig, "coverages", Arrays.asList(0.997));
		int maxDetectors = geti(jconfig, "maxDetectors", 3000);
		boolean hypothesisTesting = getb(jconfig, "hypothesisTesting", true);
		testData = getb(jconfig, "testData", true);

		int numConfigs = thresholds.size() * coverages.size();
		configurations = new ArrayList<DetectorGeneratorConfiguration>(numConfigs);
		for (int k = 0; k < coverages.size(); k++)
		{
			for (int l = 0; l < thresholds.size(); l++)
			{
				DetectorGeneratorConfiguration dconfig = new DetectorGeneratorConfiguration();

				dconfig.setHypothesisTesting(hypothesisTesting);
				dconfig.setMaxDetectors(maxDetectors);
				dconfig.setThreshold(thresholds.get(l));
				dconfig.setCoverage(coverages.get(k));
				configurations.add(dconfig);
			}
		}
	}

	public boolean getTestData()
	{
		return testData;
	}

	public void setTestData(boolean testData)
	{
		this.testData = testData;
	}

	public List<DetectorGeneratorConfiguration> getConfigurations()
	{
		return configurations;
	}

	public void setConfigurations(List<DetectorGeneratorConfiguration> configurations)
	{
		this.configurations = configurations;
	}

	public DatasetS getDataset()
	{
		return dataset;
	}

	public void setDataset(DatasetS dataset)
	{
		this.dataset = dataset;
	}

	public int getLoopsNum()
	{
		return loopsNum;
	}

	public void setLoopsNum(int loopsNum)
	{
		this.loopsNum = loopsNum;
	}

	String gets(Properties config, String key, String defaultValue)
	{
		return config.getProperty(key, defaultValue).trim();
	}

	int geti(Properties config, String key, int defaultValue)
	{
		return Integer.parseInt(gets(config, key, "" + defaultValue));
	}

	boolean getb(Properties config, String key, boolean defaultValue)
	{
		return Boolean.parseBoolean(gets(config, key, "" + defaultValue));
	}

	double getd(Properties config, String key, double defaultValue)
	{
		return Double.parseDouble(gets(config, key, "" + defaultValue));
	}

	List<Double> getdlist(Properties config, String key, List<Double> list)
	{
		String[] valuesS = gets(config, key, "" + list).split(",");
		ArrayList<Double> values = new ArrayList<Double>();
		for (int i = 0; i < valuesS.length; i++)
		{
			System.out.println("=========================================> " + valuesS[i]);
			values.add(Double.parseDouble(valuesS[i]));
		}
		return values;
	}

	private List<DetectorGeneratorConfiguration> configurations;
	private DatasetS dataset;
	private int loopsNum;
	private boolean testData;
}
