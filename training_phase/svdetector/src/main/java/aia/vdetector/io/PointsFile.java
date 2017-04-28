package aia.vdetector.io;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import aia.vdetector.Point;

public class PointsFile
{
	public PointsFile(String filename)
	{
		file = new File(filename);
	}

	public PointsFile(File file)
	{
		this.file = file;
	}

	// File format description:
	// Fields are separated by whitespace characters (they are split using regex "\s+")
	// First line of the file is a header
	// First field of header is the dimension of points
	// Third field of header may indicate points have id (keyword "hasId")
	// If the configuration says points have id, it should be the first field
	// Point rows have fields (dimension is k):
	// [<id>] component1 ... componentk [label]

	public List<Point> read() throws IOException
	{
		BufferedReader reader = new BufferedReader(new FileReader(file));
		readHeader(reader);
		List<Point> points = readPoints(reader);
		reader.close();
		return points;
	}

	public void write(List<Point> points) throws IOException
	{
		if (points == null) return;
		if (points.size() == 0) return;
		int dimension = points.get(0).getDimension();
		boolean hasId = true;

		PrintWriter writer = new PrintWriter(file);
		writeHeader(writer, dimension, hasId);
		writePoints(writer, dimension, points);
		writer.close();
	}

	private void writeHeader(PrintWriter writer, int dimension, boolean hasId) throws IOException
	{
		writer.printf("%d -1 %s\n", dimension, hasId ? "hasId" : "noId");
	}

	private void writePoints(PrintWriter writer, int dimension, List<Point> points) throws IOException
	{
		for (Point p : points)
		{
			writer.printf("%s ", p.getId());
			for (int k = 0; k < dimension; k++)
			{
				writer.printf("%s ", Point.formatter.format(p.getComponents()[k]));
			}
			writer.printf("%s\n", p.getLabel());
		}
	}

	private void readHeader(BufferedReader reader) throws IOException
	{
		String[] fields = readLineFields(reader);
		if (fields == null)
		{
			reader.close();
			throw new IOException("failed to read the header line of the points file: " + file.getName());
		}

		// First field of the header is the point dimension
		dimension = Integer.parseInt(fields[0]);
		numExpectedFields = dimension;
		fieldFirstComponent = 0;

		// If the points have id it will be the first field
		fieldId = -1;
		if (fields.length > 2 && fields[2].equals("hasId"))
		{
			fieldId = 0;
			numExpectedFields++;
			fieldFirstComponent = 1;
		}
	}

	private List<Point> readPoints(BufferedReader reader) throws IOException
	{
		List<Point> points = new ArrayList<Point>();
		int count = 0;
		double[] x = new double[dimension];
		String id;
		Point.Label label;

		for (;;)
		{
			String[] fields = readLineFields(reader);
			if (fields == null) break;

			// Id
			id = (fieldId > 0 ? fields[fieldId] : "p." + count);

			// Components
			for (int kx = 0; kx < dimension; kx++)
				x[kx] = Double.parseDouble(fields[fieldFirstComponent + kx]);

			// Label
			label = readLabel(fields);

			points.add(new Point(id, label, x));
			count++;
		}

		return points;
	}

	private Point.Label readLabel(String[] fields)
	{
		Point.Label label = Point.Label.NONE;
		if (fields.length > numExpectedFields)
		{
			int fieldLabel = numExpectedFields;

			// Try to interpret field after last point component as a Zhou Ji label
			label = tryToMapZhouJiLabel(fields[fieldLabel]);

			// If not a Zhou Ji label, try to read it as out Enum type
			if (label == null)
			{
				label = Point.Label.valueOf(fields[fieldLabel]);
			}
		}
		return label;
	}

	private Point.Label tryToMapZhouJiLabel(String zj)
	{
		if (zj.equals("0")) return Point.Label.ABNORMAL;
		else if (zj.equals("2")) return Point.Label.NORMAL;
		else return null;
	}

	private String[] readLineFields(BufferedReader reader) throws IOException
	{
		String str = reader.readLine();
		if (str == null) return null;
		return str.split(FIELD_SEPARATOR_REGEX);
	}

	private final File			file;
	private int					dimension;
	private int					numExpectedFields;
	private int					fieldId;
	private int					fieldFirstComponent;

	private static final String	FIELD_SEPARATOR_REGEX	= "\\s+";
}
