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

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  One station inside a report section: its events and the summed duration.
*/
class StationReport
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public StationReport(string name)
  {
    this.name = name;
  }

  public string getName()
  {
    return this.name;
  }

  public void addEvent(shared_ptr<ReportEvent> event)
  {
    if (event == nullptr)
      return;

    dynAppend(events, event);
    totalDurationSeconds += event.getDurationSeconds();
  }

  public dyn_anytype getEvents()
  {
    return this.events;
  }

  public int getTotalDurationSeconds()
  {
    return this.totalDurationSeconds;
  }

  public string getTotalDuration()
  {
    return ReportEvent::formatDurationSeconds(this.totalDurationSeconds);
  }

  public mapping toMapping()
  {
    mapping json;
    dyn_anytype eventMaps;

    for (int i = 1; i <= dynlen(events); i++)
    {
      shared_ptr<ReportEvent> event = events[i];
      dynAppend(eventMaps, event.toMapping());
    }

    json["name"] = this.name;
    json["events"] = eventMaps;
    json["total_duration"] = getTotalDuration();
    return json;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private string name;
  private dyn_anytype events;
  private int totalDurationSeconds;
};
