// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportEvent"
#uses "classes/reporting/ReportPeriod"
#uses "classes/reporting/ReportSection"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Fully assembled report. toMapping() is the contract with the Python
  generator and mirrors data/data.json.
*/
class ReportModel
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportModel()
  {
  }

  public void setId(string id)
  {
    this.id = id;
  }

  public string getId()
  {
    return this.id;
  }

  public void setLogoPath(string logoPath)
  {
    this.logoPath = logoPath;
  }

  public string getLogoPath()
  {
    return this.logoPath;
  }

  public void setTitle(string title)
  {
    this.title = title;
  }

  public string getTitle()
  {
    return this.title;
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

  public void setOutputDir(string outputDir)
  {
    this.outputDir = outputDir;
  }

  public string getOutputDir()
  {
    return this.outputDir;
  }

  public void setPeriod(shared_ptr<ReportPeriod> period)
  {
    this.period = period;
  }

  public shared_ptr<ReportPeriod> getPeriod()
  {
    return this.period;
  }

  public void addSection(shared_ptr<ReportSection> section)
  {
    if (section == nullptr)
      return;

    dynAppend(sections, section);
  }

  public dyn_anytype getSections()
  {
    return this.sections;
  }

  public mapping toMapping()
  {
    mapping json;
    json["logo_path"] = this.logoPath;
    json["report_title"] = this.title;
    json["report_type"] = this.reportType;
    json["generated_at"] = formatTime(ReportEvent::EVENT_TIME_FORMAT, getCurrentTime());

    if (this.period != nullptr)
      json["period"] = this.period.toMapping();
    else
      json["period"] = makeMapping("from", "", "to", "");

    json["sections"] = sectionsToMapping();
    return json;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private dyn_anytype sectionsToMapping()
  {
    dyn_anytype sectionMaps;

    for (int i = 1; i <= dynlen(sections); i++)
    {
      shared_ptr<ReportSection> section = sections[i];
      dynAppend(sectionMaps, section.toMapping());
    }

    return sectionMaps;
  }

  private string id;
  private string logoPath;
  private string title;
  private string reportType;
  private string templateName;
  private string outputDir;
  private shared_ptr<ReportPeriod> period;
  private dyn_anytype sections;
};
