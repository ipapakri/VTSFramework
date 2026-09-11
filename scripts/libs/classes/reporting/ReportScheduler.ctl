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
#uses "classes/reporting/ReportJobQueue"
#uses "classes/reporting/ReportRequest"
#uses "classes/reporting/ReportResult"
#uses "classes/reporting/ReportService"
#uses "classes/reporting/ShiftSchedule"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  At each shift boundary, enqueues a job for every definition that has
  Schedule.Enabled. Uses the same ReportJobQueue as the UI.
*/
class ReportScheduler
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  synchronized public static shared_ptr<ReportScheduler> instance()
  {
    if (scheduler == nullptr)
      scheduler = new ReportScheduler();

    return scheduler;
  }

  public void setStations(dyn_string stations)
  {
    this.stations = stations;
  }

  public void start()
  {
    if (this.started)
      return;

    this.started = true;
    startThread(this, "runLoop");
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private ReportScheduler()
  {
  }

  private void runLoop()
  {
    while (true)
    {
      time now = getCurrentTime();
      time next = now + 86400;
      dyn_string dueIds;
      bool hasDue;

      shared_ptr<ReportDefinitionRepository> repository =
          ReportService::instance().getDefinitionRepository();

      if (repository == nullptr)
      {
        delay(60);
        continue;
      }

      dyn_string ids = repository.getAllIds();

      for (int i = 1; i <= dynlen(ids); i++)
      {
        shared_ptr<ReportDefinition> definition = repository.load(ids[i]);
        if (definition == nullptr || !definition.isScheduleEnabled())
          continue;

        shared_ptr<ShiftSchedule> schedule = new ShiftSchedule(definition.getBoundaries());
        time boundary = schedule.nextBoundary(now);

        if (!hasDue || boundary < next)
        {
          next = boundary;
          dueIds = makeDynString(ids[i]);
          hasDue = true;
        }
        else if (boundary == next)
        {
          dynAppend(dueIds, ids[i]);
        }
      }

      if (!hasDue)
      {
        delay(60);
        continue;
      }

      waitUntil(next);
      generateDue(dueIds);
    }
  }

  private void waitUntil(time next)
  {
    while (getCurrentTime() < next)
    {
      int remain = (int)(next - getCurrentTime());
      if (remain < 1)
        remain = 1;
      if (remain > 30)
        remain = 30;
      delay(remain);
    }
  }

  private void generateDue(dyn_string ids)
  {
    shared_ptr<ReportDefinitionRepository> repository =
        ReportService::instance().getDefinitionRepository();

    if (repository == nullptr)
      return;

    ReportJobQueue::ensureJobDp(ReportJobQueue::SCHEDULER_JOB_DP);

    for (int i = 1; i <= dynlen(ids); i++)
    {
      shared_ptr<ReportDefinition> definition = repository.load(ids[i]);
      if (definition == nullptr)
        continue;

      shared_ptr<ShiftSchedule> schedule = new ShiftSchedule(definition.getBoundaries());
      shared_ptr<ReportRequest> request = new ReportRequest(definition.getId());
      request.setStations(this.stations);
      request.setPeriod(schedule.previousPeriod(getCurrentTime()));
      request.setUser("");

      ReportJobQueue::instance().submitTo(ReportJobQueue::SCHEDULER_JOB_DP, request);

      while (jobBusy(ReportJobQueue::SCHEDULER_JOB_DP))
        delay(1);
    }
  }

  private bool jobBusy(string dp)
  {
    int state;
    bool trigger;
    dpGet(dp + ".Result.State", state,
          dp + ".Request.Trigger", trigger);

    if (trigger)
      return true;

    return state == ReportResult::STATE_PENDING || state == ReportResult::STATE_RUNNING;
  }

  private static shared_ptr<ReportScheduler> scheduler = nullptr;
  private dyn_string stations;
  private bool started;
};
