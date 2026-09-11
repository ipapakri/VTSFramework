// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/AreaManagement/AreaManager"
#uses "classes/reporting/ReportDataProvider"
#uses "classes/reporting/ReportDefinition"
#uses "classes/reporting/ReportEvent"
#uses "classes/reporting/ReportModel"
#uses "classes/reporting/ReportPeriod"
#uses "classes/reporting/ReportRequest"
#uses "classes/reporting/ReportSection"
#uses "classes/reporting/ReportSignal"
#uses "classes/reporting/StationReport"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Assembles a ReportModel from a definition and a request. Stations the
  requesting user cannot read are dropped.
*/
class ReportBuilder
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportBuilder(mapping providers)
  {
    this.providers = providers;
  }

  public shared_ptr<ReportModel> build(shared_ptr<ReportDefinition> definition,
                                       shared_ptr<ReportRequest> request)
  {
    if (definition == nullptr || request == nullptr)
      return nullptr;

    shared_ptr<ReportPeriod> period = request.getPeriod();
    if (period == nullptr)
      return nullptr;

    shared_ptr<ReportModel> model = new ReportModel();
    model.setId(makeModelId(definition.getId()));
    model.setLogoPath(definition.getLogoPath());
    model.setTitle(definition.getTitleText());
    model.setReportType(definition.getReportType());
    model.setTemplate(definition.getTemplate());
    model.setOutputDir(definition.getOutputDir());
    model.setPeriod(period);

    dyn_string stations = permittedStations(request);

    for (int i = 1; i <= definition.getSectionCount(); i++)
    {
      shared_ptr<ReportSection> section = new ReportSection(definition.getSectionNumber(i),
                                                            definition.getSectionTitleText(i));
      shared_ptr<ReportSignal> signal = definition.getSignal(i);
      shared_ptr<ReportDataProvider> provider = resolveProvider(signal);

      for (int j = 1; j <= dynlen(stations); j++)
      {
        shared_ptr<StationReport> stationReport = new StationReport(stationLabel(stations[j]));

        if (provider != nullptr && signal != nullptr)
        {
          string dpe = signal.resolveDpe(stations[j]);
          dyn_anytype events = provider.query(dpe, period);

          for (int k = 1; k <= dynlen(events); k++)
          {
            stationReport.addEvent(events[k]);
          }
        }

        section.addStation(stationReport);
      }

      model.addSection(section);
    }

    return model;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private dyn_string permittedStations(shared_ptr<ReportRequest> request)
  {
    dyn_string requested = request.getStationDps();
    dyn_string permitted;
    string user = request.getUser();

    for (int i = 1; i <= dynlen(requested); i++)
    {
      if (!dpExists(requested[i]))
        continue;

      if (user != "" &&
          !AreaManager::instance().userHasPermission(user, requested[i], AreaManager::READ_ACCESS_BIT))
      {
        continue;
      }

      dynAppend(permitted, requested[i]);
    }

    return permitted;
  }

  private shared_ptr<ReportDataProvider> resolveProvider(shared_ptr<ReportSignal> signal)
  {
    if (signal == nullptr)
      return nullptr;

    string key = signal.getProviderKey();
    if (key == "")
      key = "value";

    if (!mappingHasKey(this.providers, key))
      return nullptr;

    return this.providers[key];
  }

  private string stationLabel(string stationDp)
  {
    string label;

    if (dpExists(stationDp + ".Internal.Label"))
      dpGet(stationDp + ".Internal.Label", label);

    if (label != "")
      return label;

    return dpSubStr(stationDp, DPSUB_DP);
  }

  private string makeModelId(string definitionId)
  {
    return definitionId + "_" + formatTime("%Y%m%d_%H%M%S", getCurrentTime());
  }

  private mapping providers;
};
