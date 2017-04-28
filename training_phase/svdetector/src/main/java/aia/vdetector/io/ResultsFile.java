package aia.vdetector.io;

import java.io.File;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import org.json.simple.JSONObject;

import aia.vdetector.DetectorGeneratorConfiguration;
import aia.vdetector.Point;
import aia.vdetector.Results;

public class ResultsFile
{

	private final File			file;
    public String 				fileName;
    private int					fileNameId;
	private int					dimension;
	private int					numExpectedFields;
	private int					fieldId;
	private int					fieldFirstComponent;
	private File				filePathResults;
	private Locale				fileLocale = new Locale("en", "US");
//	private int					auxId;

	private static final String	FIELD_SEPARATOR_REGEX	= "\\s+";
	
	public ResultsFile(String filename)
	{ 
		
//		fileName = filename;
		file = new File(filename);
		File filePath = new File(file.getParent());
//		Path dirPath = file.toPath();
//		Path dirPath = Paths.get(workingDir);
		File[] previousFiles = filePath.listFiles(new FilenameFilter() {
			@Override
			public boolean accept(File dir, String name) {
				return (name.startsWith(file.getName()));
			}
		});
		
		if (previousFiles == null) {
			fileNameId = 0;
		} else{
			System.out.println("============");
			System.out.println("previousFiles.length = " + previousFiles.length);
			fileNameId = (int) (previousFiles.length/3.0 + 1);
			System.out.println("previousFiles.length = " + fileNameId);
		}
		
//		fileName = file.getParent() + "\\" + file.getName() + "_"+ fileNameId;
		fileName = file.getParent() + "\\" + file.getName() + "_"+  String.format("%03d", fileNameId);
		filePathResults = new File(fileName); 
		filePathResults.mkdir();
		System.out.println("===============================");
		System.out.println("filePathResults " + filePathResults.toString());
	}

//	public ResultsFile(File file)
//	{
//		this.file = file;
//	}

	// File format description:
	// Fields are separated by whitespace characters (they are split using regex "\s+")
	// First line of the file is a header
	// First field of header is the dimension of points
	// Third field of header may indicate points have id (keyword "hasId")
	// If the configuration says points have id, it should be the first field
	// Point rows have fields (dimension is k):
	// [<id>] component1 ... componentk [label]
	
	public void write(Results results) throws IOException
	{
		if (results == null) return;
//		int dimension = points.get(0).getDimension();
//		boolean hasId = true;

		writeJSON(file, results.config, results.loopsNum, results.pointsNum, 
				fileNameId, fileName);
		PrintWriter writer = new PrintWriter(fileName+".data");
		writeHeader(writer);
		writeResultsArray(writer, results.resultsArray);
		writer.close();
	}
	
	
	private void writeHeader(PrintWriter writer) throws IOException
	{
		writer.printf("true.positive false.positive true.positive.rate false.positive.rate");
		writer.printf("\n");
	}

	private void writeResultsArray(PrintWriter writer, 
			ArrayList<ArrayList<Double>> resultsArray) throws IOException
	{
		for(int k = 0; k < resultsArray.size(); k++)
		{
			writer.printf(fileLocale , "%f ", resultsArray.get(k).get(0));
			writer.printf(fileLocale , "%f ", resultsArray.get(k).get(1));
			writer.printf(fileLocale , "%f ", resultsArray.get(k).get(2));
			writer.printf(fileLocale , "%f ", resultsArray.get(k).get(3));
			writer.printf("\n");
		}
	}
	
	private void writeJSON(File file, DetectorGeneratorConfiguration config,
			int loopsNum, int pointsNum, int fileNameId, String fileName) throws IOException
	{
		JSONObject obj = new JSONObject();
		obj.put("filename.id", String.format("%03d", fileNameId));
		obj.put("filename", file.getName());
		obj.put("points.num", pointsNum);
		obj.put("loops.num", loopsNum);
		obj.put("hypothesis", config.isHypothesisTesting());
		obj.put("detectors.max", config.getMaxDetectors());
		obj.put("threshold", config.getThreshold());
		obj.put("coverage", config.getCoverage());
		
//		JSONArray list = new JSONArray();
//		list.add("msg 1");
//		list.add("msg 2");
//		list.add("msg 3");
//
//		obj.put("messages", list);

		try {

//			FileWriter file = new FileWriter("c:/Users/clotetx/Eclipse_workspace/preemptive/tests/test.json");
			FileWriter file1 = new FileWriter(fileName+".json");
			file1.write(obj.toJSONString());
			file1.flush();
			file1.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

		System.out.print(obj);

	}

	public String getFileName()
	{
		return fileName;
	}

	public int getFileNameId()
	{
		return fileNameId;
	}
	
	public String getFileNameParent()
	{
		return file.getParent();
	}
	
	public String getFilePathResults()
	{
		return filePathResults.toString();
	}
}
