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
  Translates between the stations an operator picks and the datapoints a report
  is built from. A project that numbers its stations resolves the numbers here;
  one that does not can pass datapoint names straight through.
*/
class StationCatalog
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public StationCatalog()
  {
  }

  /**
    Every station datapoint, in display order.
  */
  public dyn_string getAllDps()
  {
    return makeDynString();
  }

  /**
    The station numbers as datapoint names, silently dropping the ones the
    project does not know.
  */
  public dyn_string resolve(const dyn_int& numbers)
  {
    throw(makeError("", PRIO_SEVERE, ERR_IMPL, 1, "Method resolve is abstract in this context, \"StationCatalog\""));
    return makeDynString();
  }

  /**
    What the station is called in the report. Falls back to the datapoint name
    so an unlabelled station is still identifiable.
  */
  public string getLabel(string stationDp)
  {
    return dpSubStr(stationDp, DPSUB_DP);
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
};
