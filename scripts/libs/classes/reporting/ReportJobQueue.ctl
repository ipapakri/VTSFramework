// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportPeriod"
#uses "classes/reporting/ReportRequest"
#uses "classes/reporting/ReportResult"
#uses "classes/reporting/ReportService"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Datapoint-backed queue. The UI dpSets a _ReportJob; this class consumes
  Trigger on a CTRL manager and writes Result.* back.
*/
class ReportJobQueue
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  public static const string DPT_NAME = "_ReportJob";
  public static const string SCHEDULER_JOB_DP = "_ReportJob_Scheduler";

  synchronized public static shared_ptr<ReportJobQueue> instance()
  {
    if (jobQueue == nullptr)
      jobQueue = new ReportJobQueue();

    return jobQueue;
  }

  /**
    Creates the manager's job DP if needed and sets Trigger. Returns the DP
    so a panel can connect to Result.*.
  */
  public string submit(shared_ptr<ReportRequest> request)
  {
    if (request == nullptr)
      return "";

    string dp = jobDpForCurrentManager();
    ensureJobDp(dp);
    writeRequest(dp, request);
    return dp;
  }

  public string submitTo(string dp, shared_ptr<ReportRequest> request)
  {
    if (request == nullptr || dp == "")
      return "";

    ensureJobDp(dp);
    writeRequest(dp, request);
    return dp;
  }

  public void start()
  {
    if (this.started)
      return;

    string query = "SELECT '_original.._value' FROM '*.Request.Trigger' WHERE _DPT = \"" + DPT_NAME + "\"";
    if (dpQueryConnectSingle(this, "onTrigger", true, "", query) == 0)
      this.started = true;
    else
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Could not connect to report jobs");
  }

  public static string jobDpForCurrentManager()
  {
    return "_ReportJob_M" + (string)myManNum();
  }

  public static void ensureJobDp(string dp)
  {
    if (dpExists(dp))
      return;

    dpCreate(dp, DPT_NAME);
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private ReportJobQueue()
  {
  }

  private void onTrigger(string userData, dyn_dyn_anytype table)
  {
    for (int i = 2; i <= dynlen(table); i++)
    {
      if (dynlen(table[i]) < 2)
        continue;

      bool trigger = (bool)table[i][2];
      if (!trigger)
        continue;

      string dpe = (string)table[i][1];
      string dp = dpSubStr(dpe, DPSUB_DP);
      processJob(dp);
    }
  }

  private void processJob(string dp)
  {
    dpSet(dp + ".Request.Trigger", false,
          dp + ".Result.State", ReportResult::STATE_RUNNING,
          dp + ".Result.Error", "",
          dp + ".Result.PdfPath", "");

    shared_ptr<ReportRequest> request = readRequest(dp);
    shared_ptr<ReportResult> result = ReportService::instance().generate(request);

    if (result == nullptr)
    {
      dpSet(dp + ".Result.State", ReportResult::STATE_ERROR,
            dp + ".Result.Error", "No result");
      return;
    }

    dpSet(dp + ".Result.State", result.getState(),
          dp + ".Result.PdfPath", result.getPdfPath(),
          dp + ".Result.Error", result.getError());
  }

  private void writeRequest(string dp, shared_ptr<ReportRequest> request)
  {
    time fromTime, toTime;
    shared_ptr<ReportPeriod> period = request.getPeriod();
    if (period != nullptr)
    {
      fromTime = period.getFrom();
      toTime = period.getTo();
    }

    dpSet(dp + ".Request.DefinitionId", request.getDefinitionId(),
          dp + ".Request.StationDps", request.getStationDps(),
          dp + ".Request.From", fromTime,
          dp + ".Request.To", toTime,
          dp + ".Request.User", request.getUser(),
          dp + ".Result.State", ReportResult::STATE_PENDING,
          dp + ".Result.PdfPath", "",
          dp + ".Result.Error", "",
          dp + ".Request.Trigger", true);
  }

  private shared_ptr<ReportRequest> readRequest(string dp)
  {
    string definitionId, user;
    dyn_string stations;
    time fromTime, toTime;

    dpGet(dp + ".Request.DefinitionId", definitionId,
          dp + ".Request.StationDps", stations,
          dp + ".Request.From", fromTime,
          dp + ".Request.To", toTime,
          dp + ".Request.User", user);

    shared_ptr<ReportRequest> request = new ReportRequest(definitionId);
    request.setStations(stations);
    request.setPeriod(new ReportPeriod(fromTime, toTime));
    request.setUser(user);
    return request;
  }

  private static shared_ptr<ReportJobQueue> jobQueue = nullptr;
  private bool started;
};
