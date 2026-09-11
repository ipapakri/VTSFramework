// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportFormat"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  One start/stop interval of a binary signal, plus the duration string the
  Jinja template prints as a table row.
*/
class ReportEvent
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  public static const string EVENT_TIME_FORMAT = "%d/%m/%Y %H:%M:%S";

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportEvent(time start, time stop)
  {
    this.start = start;
    this.stop = stop;
    this.durationSeconds = secondsBetween(start, stop);
  }

  public time getStart()
  {
    return this.start;
  }

  public time getStop()
  {
    return this.stop;
  }

  public int getDurationSeconds()
  {
    return this.durationSeconds;
  }

  public string formatDuration()
  {
    return formatDurationSeconds(this.durationSeconds);
  }

  public static int secondsBetween(time start, time stop)
  {
    int seconds = (int)(stop - start);

    if (seconds < 0)
      return 0;

    return seconds;
  }

  /**
    Matches the sample JSON: "0 Ώρες, 0 Λεπτά, 1 Δευτ."
  */
  public static string formatDurationSeconds(int seconds)
  {
    return ReportFormat::duration(seconds);
  }

  public static string formatEventTime(time value)
  {
    return ReportFormat::timestamp(value);
  }

  public mapping toMapping()
  {
    mapping json;
    json["start"] = formatEventTime(this.start);
    json["stop"] = formatEventTime(this.stop);
    json["duration"] = formatDuration();
    return json;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private time start;
  private time stop;
  private int durationSeconds;
};
