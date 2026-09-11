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
  Turns one DPE over a period into ReportEvent objects. Alert archive and
  value archive are the two starting implementations.
*/
class ReportDataProvider
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportDataProvider()
  {
  }

  public dyn_anytype query(string dpe, shared_ptr<ReportPeriod> period)
  {
    throw(makeError("", PRIO_SEVERE, ERR_IMPL, 1,
                    "Method query is abstract in this context, \"ReportDataProvider\""));
    return makeDynAnytype();
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
};
