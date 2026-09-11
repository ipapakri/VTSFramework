// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportBuilder"
#uses "classes/reporting/ReportDataProvider"
#uses "classes/reporting/ReportDefinition"
#uses "classes/reporting/ReportDefinitionRepository"
#uses "classes/reporting/ReportExporter"
#uses "classes/reporting/ReportModel"
#uses "classes/reporting/ReportRequest"
#uses "classes/reporting/ReportResult"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Facade used by the job queue and the scheduler. The UI never calls
  generate() itself because system() would block the UI manager.
*/
class ReportService
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  synchronized public static shared_ptr<ReportService> instance()
  {
    if (reportService == nullptr)
      reportService = new ReportService();

    return reportService;
  }

  public void setDefinitionRepository(shared_ptr<ReportDefinitionRepository> repository)
  {
    this.repository = repository;
  }

  public shared_ptr<ReportDefinitionRepository> getDefinitionRepository()
  {
    return this.repository;
  }

  public void registerProvider(string key, shared_ptr<ReportDataProvider> provider)
  {
    this.providers[key] = provider;
  }

  public void setExporter(shared_ptr<ReportExporter> exporter)
  {
    this.exporter = exporter;
  }

  public shared_ptr<ReportResult> generate(shared_ptr<ReportRequest> request)
  {
    shared_ptr<ReportResult> result = new ReportResult();
    result.setState(ReportResult::STATE_RUNNING);

    if (request == nullptr)
    {
      result.setError("No report request");
      return result;
    }

    if (this.repository == nullptr)
    {
      result.setError("No definition repository");
      return result;
    }

    if (this.exporter == nullptr)
    {
      result.setError("No report exporter");
      return result;
    }

    shared_ptr<ReportDefinition> definition = this.repository.load(request.getDefinitionId());
    if (definition == nullptr)
    {
      result.setError("Unknown report definition: " + request.getDefinitionId());
      return result;
    }

    if (request.getPeriod() == nullptr)
    {
      result.setError("No report period");
      return result;
    }

    shared_ptr<ReportBuilder> builder = new ReportBuilder(this.providers);
    shared_ptr<ReportModel> model = builder.build(definition, request);

    if (model == nullptr)
    {
      result.setError("Could not build report model");
      return result;
    }

    string outputFile = outputPath(definition, model);
    if (!this.exporter.export(model, outputFile))
    {
      string error = this.exporter.getLastError();
      if (error == "")
        error = "Export failed";
      result.setError(error);
      return result;
    }

    result.setOk(outputFile);
    return result;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private ReportService()
  {
  }

  private string outputPath(shared_ptr<ReportDefinition> definition, shared_ptr<ReportModel> model)
  {
    string dir = definition.getOutputDir();
    if (dir == "")
      dir = getPath(DATA_REL_PATH) + "reports";

    if (strlen(dir) > 0)
    {
      string last = substr(dir, strlen(dir) - 1, 1);
      if (last != "/" && last != "\\")
        dir += "/";
    }

    return dir + model.getId() + ".pdf";
  }

  private static shared_ptr<ReportService> reportService = nullptr;
  private shared_ptr<ReportDefinitionRepository> repository;
  private mapping providers;
  private shared_ptr<ReportExporter> exporter;
};
