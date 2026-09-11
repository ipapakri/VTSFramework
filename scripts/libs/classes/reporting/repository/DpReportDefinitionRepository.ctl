// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportDefinition"
#uses "classes/reporting/ReportDefinitionRepository"
#uses "classes/reporting/ReportSignal"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Reads _ReportDefinition datapoints. Parallel dyn arrays on Sections.* are
  the same storage pattern as UserPermissions.Areas / Permissions.
*/
class DpReportDefinitionRepository : ReportDefinitionRepository
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  public static const string DPT_NAME = "_ReportDefinition";

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public DpReportDefinitionRepository()
  {
  }

  public shared_ptr<ReportDefinition> load(string id)
  {
    string dp = toDp(id);

    if (dp == "" || !dpExists(dp))
      return nullptr;

    langString title;
    string reportType, templateName, logoPath, outputDir;
    dyn_int numbers;
    dyn_langString titles;
    dyn_string suffixes, providerKeys, boundaries;
    bool scheduleEnabled;

    dpGet(dp + ".Header.Title", title,
          dp + ".Header.ReportType", reportType,
          dp + ".Header.Template", templateName,
          dp + ".Header.LogoPath", logoPath,
          dp + ".Header.OutputDir", outputDir,
          dp + ".Sections.Numbers", numbers,
          dp + ".Sections.Titles", titles,
          dp + ".Sections.SignalSuffix", suffixes,
          dp + ".Sections.ProviderKey", providerKeys,
          dp + ".Schedule.Enabled", scheduleEnabled,
          dp + ".Schedule.Boundaries", boundaries);

    shared_ptr<ReportDefinition> definition = new ReportDefinition(dpSubStr(dp, DPSUB_DP));
    definition.setTitle(title);
    definition.setReportType(reportType);
    definition.setTemplate(templateName);
    definition.setLogoPath(logoPath);
    definition.setOutputDir(outputDir);
    definition.setScheduleEnabled(scheduleEnabled);
    definition.setBoundaries(boundaries);

    int count = dynlen(numbers);
    if (dynlen(titles) > count) count = dynlen(titles);
    if (dynlen(suffixes) > count) count = dynlen(suffixes);
    if (dynlen(providerKeys) > count) count = dynlen(providerKeys);

    for (int i = 1; i <= count; i++)
    {
      int number = i;
      langString sectionTitle;
      string suffix, providerKey;

      if (i <= dynlen(numbers))
        number = numbers[i];
      if (i <= dynlen(titles))
        sectionTitle = titles[i];
      if (i <= dynlen(suffixes))
        suffix = suffixes[i];
      if (i <= dynlen(providerKeys))
        providerKey = providerKeys[i];

      definition.addSection(number, sectionTitle, new ReportSignal(suffix, providerKey));
    }

    return definition;
  }

  public dyn_string getAllIds()
  {
    dyn_string dps = dpNames("*", DPT_NAME);
    dyn_string ids;

    for (int i = 1; i <= dynlen(dps); i++)
    {
      dynAppend(ids, dpSubStr(dps[i], DPSUB_DP));
    }

    return ids;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private string toDp(string id)
  {
    if (id == "")
      return "";

    if (dpExists(id))
      return id;

    string withSystem = getSystemName() + id;
    if (dpExists(withSystem))
      return withSystem;

    return id;
  }
};
