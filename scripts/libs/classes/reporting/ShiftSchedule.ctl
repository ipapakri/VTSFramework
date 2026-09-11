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

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Shift windows from times-of-day such as "22:00". A single boundary is a
  24-hour window; several boundaries split the day into consecutive shifts.
*/
class ShiftSchedule
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ShiftSchedule(dyn_string boundaries)
  {
    this.boundaries = normalizeBoundaries(boundaries);
  }

  /**
    Window that contains `reference`: [last boundary at or before it, next
    boundary after it).
  */
  public shared_ptr<ReportPeriod> periodFor(time reference)
  {
    time start = boundaryAtOrBefore(reference);
    time stop = nextBoundary(start);
    return new ReportPeriod(start, stop);
  }

  /**
    Last completed window. At a boundary this is the window that just ended,
    which is what the scheduler generates.
  */
  public shared_ptr<ReportPeriod> previousPeriod(time reference)
  {
    time stop = boundaryAtOrBefore(reference);
    time start = previousBoundary(stop);
    return new ReportPeriod(start, stop);
  }

  /**
    Smallest boundary strictly after `reference`.
  */
  public time nextBoundary(time reference)
  {
    dyn_time candidates = boundariesOnDay(reference);
    dynAppend(candidates, boundariesOnDay(reference + 86400));

    time next = candidates[dynlen(candidates)];
    bool found;

    for (int i = 1; i <= dynlen(candidates); i++)
    {
      if (candidates[i] > reference && (!found || candidates[i] < next))
      {
        next = candidates[i];
        found = true;
      }
    }

    return next;
  }

  public dyn_string getBoundaries()
  {
    return this.boundaries;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private dyn_string normalizeBoundaries(dyn_string values)
  {
    dyn_string cleaned;

    for (int i = 1; i <= dynlen(values); i++)
    {
      if (values[i] != "")
        dynAppend(cleaned, values[i]);
    }

    if (dynlen(cleaned) == 0)
      dynAppend(cleaned, "22:00");

    dynSort(cleaned);
    dynUnique(cleaned);
    return cleaned;
  }

  private time boundaryAtOrBefore(time reference)
  {
    dyn_time candidates = boundariesOnDay(reference);
    dynAppend(candidates, boundariesOnDay(reference - 86400));

    time best = candidates[1];
    bool found;

    for (int i = 1; i <= dynlen(candidates); i++)
    {
      if (candidates[i] <= reference && (!found || candidates[i] > best))
      {
        best = candidates[i];
        found = true;
      }
    }

    return best;
  }

  private time previousBoundary(time boundary)
  {
    return boundaryAtOrBefore(boundary - 1);
  }

  private dyn_time boundariesOnDay(time dayRef)
  {
    dyn_time result;

    for (int i = 1; i <= dynlen(this.boundaries); i++)
    {
      int hour, minute;
      if (!parseHm(this.boundaries[i], hour, minute))
        continue;

      time value = makeTime(year(dayRef), month(dayRef), day(dayRef), hour, minute, 0);
      dynAppend(result, value);
    }

    return result;
  }

  private bool parseHm(string text, int &hour, int &minute)
  {
    dyn_string parts = strsplit(text, ":");
    if (dynlen(parts) < 2)
      return false;

    hour = (int)parts[1];
    minute = (int)parts[2];
    return true;
  }

  private dyn_string boundaries;
};
