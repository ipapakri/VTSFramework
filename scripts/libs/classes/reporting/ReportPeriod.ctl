// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Inclusive start / exclusive-or-equal end of a report. Built either from a
  free time range or from a ShiftSchedule window.
*/
class ReportPeriod
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportPeriod(time fromTime, time toTime)
  {
    this.fromTime = fromTime;
    this.toTime = toTime;
  }

  public time getFrom()
  {
    return this.fromTime;
  }

  public time getTo()
  {
    return this.toTime;
  }

  public string getLabel()
  {
    return formatPeriodTime(this.fromTime) + " - " + formatPeriodTime(this.toTime);
  }

  /**
    Matches the sample JSON period fields: "28 Ιουλ 2026 22:00:00".
  */
  public static string formatPeriodTime(time value)
  {
    dyn_string months = makeDynString("Ιαν", "Φεβ", "Μαρ", "Απρ", "Μαϊ", "Ιουν",
                                      "Ιουλ", "Αυγ", "Σεπ", "Οκτ", "Νοε", "Δεκ");
    int monthIndex = month(value);
    string monthName = (string)monthIndex;

    if (monthIndex >= 1 && monthIndex <= dynlen(months))
      monthName = months[monthIndex];

    return (string)day(value) + " " + monthName + " " + (string)year(value) + " " +
           formatTime("%H:%M:%S", value);
  }

  public mapping toMapping()
  {
    mapping json;
    json["from"] = formatPeriodTime(this.fromTime);
    json["to"] = formatPeriodTime(this.toTime);
    return json;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private time fromTime;
  private time toTime;
};
