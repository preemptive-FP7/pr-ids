package aia.vdetector;

public class DatasetS
{

	public DatasetS(String folderIn, String fileName, String agentName)
	{
		this.folderIn = folderIn;
		this.fileName = fileName;
		this.agentName = agentName;

		this.folderOut = folderIn + agentName;

		this.trainFilename = folderIn + fileName + "_train.vd";
		this.testFilename = folderIn + fileName + "_testcheck.vd";
		this.evalFilename = folderIn + fileName + "_test.vd";
		this.configFilename = folderOut + fileName + "_testcheck";
	}

	public String getFolderIn()
	{
		return folderIn;
	}

	public String getFileName()
	{
		return fileName;
	}

	public String getAgentName()
	{
		return agentName;
	}

	public String getFolderOut()
	{
		return folderOut;
	}

	public String getVdFilename()
	{
		return vdFilename;
	}

	public String getEvalFilename()
	{
		return evalFilename;
	}

	public String getTestFilename()
	{
		return testFilename;
	}

	public String getTrainFilename()
	{
		return trainFilename;
	}

	public String getConfigFilename()
	{
		return configFilename;
	}

	public String getOutputFilename()
	{
		return outputFilename;
	}

	final String folderOut;
	final String vdFilename = "vdetector_test.txt";
	final String evalFilename;
	final String testFilename;
	final String trainFilename;
	final String configFilename;
	final String outputFilename = "evaluated_test.txt";
	final String folderIn;
	final String fileName;
	final String agentName;
}
