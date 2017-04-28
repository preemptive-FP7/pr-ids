package aia.vdetector.io;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import aia.vdetector.Detector;
import aia.vdetector.Point;

public class DetectorsFile
{
	public DetectorsFile(String filename)
	{
		file = new File(filename);
	}

	public DetectorsFile(File file)
	{
		this.file = file;
	}

	// File format description:
	// Fields are separated by whitespace characters (they are split using regex "\s+")
	// First line of the file is a header
	// First field of header is the dimension of detector points
	// Detector rows have fields (dimension is k):
	// [<name>] radius^2 centerComponent1 ... centerComponentk

	public List<Detector> read() throws IOException
	{
		BufferedReader reader = new BufferedReader(new FileReader(file));
		readHeader(reader);
		List<Detector> detectors = readDetectors(reader);
		reader.close();
		return detectors;
	}

	public void write(List<Detector> detectors) throws IOException
	{
		if (detectors == null) return;
		if (detectors.size() == 0) return;
		int dimension = detectors.get(0).getCenter().getDimension();

		PrintWriter writer = new PrintWriter(file);
		writeHeader(writer, dimension);
		writeDetectors(writer, dimension, detectors);
		writer.close();
	}

	private void writeHeader(PrintWriter writer, int dimension) throws IOException
	{
		writer.printf("%d\n", dimension);
	}

	private void writeDetectors(PrintWriter writer, int dimension, List<Detector> detectors) throws IOException
	{
		for (Detector d : detectors)
		{
			writer.printf("%s %s ", d.getName(), Point.formatter.format(d.getRadius()));
//			writer.printf("%s %s ", d.getName(), Point.printformat(d.getRadius()));
			for (int k = 0; k < dimension; k++)
			{
				writer.printf("%s ", Point.formatter.format(d.getCenter().getComponents()[k]));
//				writer.printf("%s ", Point.printformat(d.getCenter().getComponents()[k]));
			}
			writer.print("\n");
		}
	}

	private void readHeader(BufferedReader reader) throws IOException
	{
		String[] fields = readLineFields(reader);
		if (fields == null)
		{
			reader.close();
			throw new IOException("failed to read the header line of the detectors file: " + file.getName());
		}

		// First field of the header is the point dimension
		dimension = Integer.parseInt(fields[0]);
	}

	private List<Detector> readDetectors(BufferedReader reader) throws IOException
	{
		List<Detector> detectors = new ArrayList<Detector>();
		String name;
		double radius;
		double[] x = new double[dimension];

		for (;;)
		{
			String[] fields = readLineFields(reader);
			if (fields == null) break;

			// Name and radius
			name = fields[0];
			radius = Double.parseDouble(fields[1]);

			// Components
			for (int kx = 0; kx < dimension; kx++)
				x[kx] = Double.parseDouble(fields[2 + kx]);

			Point center = new Point(name + "-center", Point.Label.NORMAL, x);
			Detector d = new Detector(center, radius);
			d.setName(name);
			detectors.add(d);
		}

		return detectors;
	}

	private String[] readLineFields(BufferedReader reader) throws IOException
	{
		String str = reader.readLine();
		if (str == null) return null;
		return str.split(FIELD_SEPARATOR_REGEX);
	}

	private final File			file;
	private int					dimension;

	private static final String	FIELD_SEPARATOR_REGEX	= "\\s+";
}
