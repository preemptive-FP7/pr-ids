package aia.vdetector;

import java.util.ArrayList;

public class Results
{
    //
    public int pointsNum;
    public int loopsNum;
    public int fileNameId;
    public String fileName;
    public DetectorGeneratorConfiguration config;
    public ArrayList<ArrayList<Double>> resultsArray;
        
    //double[] x  ArrayList<ArrayList<Double>> output = new ArrayList<ArrayList<Double>>();
    
    // constructor A
    public Results(int startPointsNum, int startLoopsNum, String startFileName, 
    		DetectorGeneratorConfiguration startConfig, 
    		ArrayList<ArrayList<Double>> startResults, int startFileNameId) {
    	fileNameId = startFileNameId;
        pointsNum = startPointsNum;
        loopsNum = startLoopsNum;
        fileName = startFileName;
    	config = startConfig;
    	resultsArray = startResults;
    }
    
    // constructor B (empty)
    public Results()
	{
    	resultsArray = new ArrayList<ArrayList<Double>>();
	}

	// methods      
    public void addResultsArray(ArrayList<Double> newValue) {
    	resultsArray.add(newValue);
    }
    
    public void setPointsNum(int newValue) {
    	pointsNum = newValue;
    }
    
    public void setLoopsNum(int newValue) {
    	loopsNum = newValue;
    }
    
    public void setFileName(String newValue) {
    	fileName = newValue;
    }
        
    public void setConfig(DetectorGeneratorConfiguration newValue) {
    	config = newValue;
    }
    
    public ArrayList<ArrayList<Double>> getResultsArray() {
    	return resultsArray;
    }
    
    public int getPointsNum() {
    	return pointsNum;
    }
    
    public int getLoopsNum() {
    	return loopsNum;
    }
    
}
