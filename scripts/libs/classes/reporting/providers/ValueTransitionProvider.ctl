// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportDataProvider"
#uses "classes/reporting/ReportEvent"
#uses "classes/reporting/ReportPeriod"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Binary value-archive transitions 0->1->0. A signal already TRUE at `from`
  is clamped to the period start; one still TRUE at `to` is clamped to the
  period end.
*/
class ValueTransitionProvider : ReportDataProvider
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ValueTransitionProvider()
  {
  }

  public dyn_anytype query(string dpe, shared_ptr<ReportPeriod> period)
  {
    dyn_anytype events;

    if (period == nullptr || dpe == "" || !dpExists(dpe))
      return events;

    anytype startValue;
    dpGetAsynch(period.getFrom(), dpe, startValue);

    dyn_time times;
    dyn_anytype values;
    dpGetPeriod(period.getFrom(), period.getTo(), 0, dpe, times, values);

    bool active = isActive(startValue);
    time eventStart = period.getFrom();

    for (int i = 1; i <= dynlen(times); i++)
    {
      bool nowActive = isActive(values[i]);

      if (!active && nowActive)
      {
        eventStart = times[i];
        active = true;
      }
      else if (active && !nowActive)
      {
        dynAppend(events, new ReportEvent(eventStart, times[i]));
        active = false;
      }
    }

    if (active)
      dynAppend(events, new ReportEvent(eventStart, period.getTo()));

    return events;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private bool isActive(anytype value)
  {
    if (getType(value) == BOOL_VAR)
      return (bool)value;

    return (int)value != 0;
  }
};
