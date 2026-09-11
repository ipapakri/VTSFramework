// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportExporter"
#uses "classes/reporting/ReportModel"
#uses "classes/reporting/ReportSerializer"
#uses "classes/reporting/serializer/JsonReportSerializer"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Writes JSON then runs main.py via system(). The UI never calls this;
  ReportJobQueue does, on a dedicated CTRL manager.
*/
class PythonPdfExporter : ReportExporter
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public PythonPdfExporter(string pythonExecutable, string scriptPath)
  {
    this.pythonExecutable = pythonExecutable;
    this.scriptPath = scriptPath;
    this.serializer = new JsonReportSerializer();
  }

  public void setSerializer(shared_ptr<ReportSerializer> serializer)
  {
    this.serializer = serializer;
  }

  public bool export(shared_ptr<ReportModel> model, string outputFile)
  {
    this.lastError = "";

    if (model == nullptr)
    {
      this.lastError = "No report model";
      return false;
    }

    if (this.scriptPath == "" || !isfile(this.scriptPath))
    {
      this.lastError = "Python script not found: " + this.scriptPath;
      return false;
    }

    string jsonFile = jsonPath(model);
    if (!this.serializer.write(model, jsonFile))
    {
      this.lastError = "Could not write JSON: " + jsonFile;
      return false;
    }

    string errFile = jsonFile + ".err";
    string command = this.pythonExecutable + " " + quote(this.scriptPath) +
                     " --data " + quote(jsonFile) +
                     " --template " + quote(model.getTemplate()) +
                     " --output " + quote(outputFile) +
                     " 2> " + quote(errFile);

    int rc = system(command);

    if (rc != 0 || !isfile(outputFile))
    {
      this.lastError = "PDF export failed (rc=" + (string)rc + ")";
      string stderrText = readFileText(errFile);
      if (stderrText != "")
        this.lastError += ": " + stderrText;
      return false;
    }

    return true;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private string jsonPath(shared_ptr<ReportModel> model)
  {
    string dir = getPath(DATA_REL_PATH) + "reports/tmp";
    return dir + "/" + model.getId() + ".json";
  }

  private string quote(string value)
  {
    strreplace(value, "\"", "\\\"");
    return "\"" + value + "\"";
  }

  private string readFileText(string fileName)
  {
    if (!isfile(fileName))
      return "";

    string text;
    fileToString(fileName, text);
    strreplace(text, "\n", " ");
    return text;
  }

  private string pythonExecutable;
  private string scriptPath;
  private shared_ptr<ReportSerializer> serializer;
};
