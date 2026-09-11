// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportSignal"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Stored description of a report: header, sections/signals, optional shift
  schedule. Loaded from a _ReportDefinition datapoint.
*/
class ReportDefinition
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportDefinition(string id)
  {
    this.id = id;
  }

  public string getId()
  {
    return this.id;
  }

  public void setTitle(langString title)
  {
    this.title = title;
  }

  public langString getTitle()
  {
    return this.title;
  }

  public string getTitleText()
  {
    return this.title.text();
  }

  public void setReportType(string reportType)
  {
    this.reportType = reportType;
  }

  public string getReportType()
  {
    return this.reportType;
  }

  public void setTemplate(string templateName)
  {
    this.templateName = templateName;
  }

  public string getTemplate()
  {
    return this.templateName;
  }

  public void setLogoPath(string logoPath)
  {
    this.logoPath = logoPath;
  }

  public string getLogoPath()
  {
    return this.logoPath;
  }

  public void setOutputDir(string outputDir)
  {
    this.outputDir = outputDir;
  }

  public string getOutputDir()
  {
    return this.outputDir;
  }

  public void addSection(int number, langString title, shared_ptr<ReportSignal> signal)
  {
    dynAppend(sectionNumbers, number);
    dynAppend(sectionTitles, title);
    dynAppend(signals, signal);
  }

  public int getSectionCount()
  {
    return dynlen(sectionNumbers);
  }

  public int getSectionNumber(int index)
  {
    if (index < 1 || index > dynlen(sectionNumbers))
      return index;

    return sectionNumbers[index];
  }

  public langString getSectionTitle(int index)
  {
    langString title;

    if (index < 1 || index > dynlen(sectionTitles))
      return title;

    return sectionTitles[index];
  }

  public string getSectionTitleText(int index)
  {
    langString title = getSectionTitle(index);
    return title.text();
  }

  public shared_ptr<ReportSignal> getSignal(int index)
  {
    if (index < 1 || index > dynlen(signals))
      return nullptr;

    return signals[index];
  }

  public void setScheduleEnabled(bool enabled)
  {
    this.scheduleEnabled = enabled;
  }

  public bool isScheduleEnabled()
  {
    return this.scheduleEnabled;
  }

  public void setBoundaries(dyn_string boundaries)
  {
    this.boundaries = boundaries;
  }

  public dyn_string getBoundaries()
  {
    return this.boundaries;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private string id;
  private langString title;
  private string reportType;
  private string templateName;
  private string logoPath;
  private string outputDir;
  private dyn_int sectionNumbers;
  private dyn_langString sectionTitles;
  private dyn_anytype signals;
  private bool scheduleEnabled;
  private dyn_string boundaries;
};
