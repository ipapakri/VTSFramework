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
  Came/went pairs from the alert archive. An alert already active at `from`
  still counts; one still active at `to` is closed at the period end.
*/
class AlertEventProvider : ReportDataProvider
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public AlertEventProvider()
  {
  }

  public dyn_anytype query(string dpe, shared_ptr<ReportPeriod> period)
  {
    dyn_anytype events;

    if (period == nullptr || dpe == "" || !dpExists(dpe))
      return events;

    dyn_time times;
    dyn_int states;
    readAlertHistory(dpe, period, times, states);

    bool active = alertActiveAt(dpe, period.getFrom());
    time eventStart = period.getFrom();

    for (int i = 1; i <= dynlen(times); i++)
    {
      if (times[i] < period.getFrom() || times[i] > period.getTo())
        continue;

      bool nowActive = isActiveState(states[i]);

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
      else if (!active && !nowActive)
      {
        dynAppend(events, new ReportEvent(period.getFrom(), times[i]));
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

  /**
    ALERT TIMERANGE query: column 1 is the DPE, column 2 the timestamp,
    column 3 the alert state (0 = went, != 0 = came).
  */
  private void readAlertHistory(string dpe, shared_ptr<ReportPeriod> period,
                                dyn_time &times, dyn_int &states)
  {
    string fromStr = formatTime("%Y.%m.%d %H:%M:%S.000", period.getFrom());
    string toStr = formatTime("%Y.%m.%d %H:%M:%S.000", period.getTo());
    string query = "SELECT ALERT '_alert_hdl.._value' FROM '" + dpe +
                   "' TIMERANGE(\"" + fromStr + "\", \"" + toStr + "\", 1, 0)";

    dyn_dyn_anytype table;
    if (dpQuery(query, table) != 0)
      return;

    for (int i = 2; i <= dynlen(table); i++)
    {
      if (dynlen(table[i]) < 3)
        continue;

      dynAppend(times, (time)table[i][2]);
      dynAppend(states, (int)table[i][3]);
    }
  }

  private bool alertActiveAt(string dpe, time at)
  {
    dyn_anytype values;
    if (alertGet(at, dpe, values) != 0)
      return false;

    if (dynlen(values) < 1)
      return false;

    return isActiveState((int)values[1]);
  }

  private bool isActiveState(int state)
  {
    return state != 0;
  }
};
