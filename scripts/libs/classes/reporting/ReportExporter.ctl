// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportModel"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Turns a ReportModel into an output file. Python PDF is the first
  implementation; an HTTP transport would replace only this class.
*/
class ReportExporter
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportExporter()
  {
  }

  public bool export(shared_ptr<ReportModel> model, string outputFile)
  {
    throw(makeError("", PRIO_SEVERE, ERR_IMPL, 1,
                    "Method export is abstract in this context, \"ReportExporter\""));
    return false;
  }

  public string getLastError()
  {
    return this.lastError;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------
  protected string lastError;

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
};
