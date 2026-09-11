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
  The textual conventions every report value object formats itself with. The
  patterns are static so a project sets them once at startup instead of passing
  a formatter down to every event.
*/
class ReportFormat
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportFormat()
  {
  }

  public static void setTimestampPattern(string pattern)
  {
    timestampPattern = pattern;
  }

  public static void setPeriodPattern(string pattern)
  {
    periodPattern = pattern;
  }

  /**
    %H, %M and %S are replaced by the hour, minute and second parts of a
    duration. They are not zero padded: a duration of one second reads
    "0 ... 0 ... 1 ...".
  */
  public static void setDurationPattern(string pattern)
  {
    durationPattern = pattern;
  }

  public static string timestamp(time value)
  {
    return formatTime(timestampPattern, value);
  }

  public static string periodBound(time value)
  {
    return formatTime(periodPattern, value);
  }

  public static string duration(int totalSeconds)
  {
    if (totalSeconds < 0)
    {
      totalSeconds = 0;
    }

    string text = durationPattern;

    strreplace(text, "%H", (string)(totalSeconds / 3600));
    strreplace(text, "%M", (string)((totalSeconds % 3600) / 60));
    strreplace(text, "%S", (string)(totalSeconds % 60));

    return text;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private static string timestampPattern = "%d/%m/%Y %H:%M:%S";
  private static string periodPattern = "%d %b %Y %H:%M:%S";
  private static string durationPattern = "%H Ώρες, %M Λεπτά, %S Δευτ.";
};
