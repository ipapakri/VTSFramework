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
  Writes a ReportModel to a file. JSON is the format the Python generator
  already reads.
*/
class ReportSerializer
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportSerializer()
  {
  }

  public bool write(shared_ptr<ReportModel> model, string fileName)
  {
    throw(makeError("", PRIO_SEVERE, ERR_IMPL, 1,
                    "Method write is abstract in this context, \"ReportSerializer\""));
    return false;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
};
