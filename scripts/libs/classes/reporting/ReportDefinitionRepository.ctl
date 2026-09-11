// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportDefinition"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Loads report definitions. CNS-free projects store them as datapoints;
  another project can swap in a file-backed repository.
*/
class ReportDefinitionRepository
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportDefinitionRepository()
  {
  }

  public shared_ptr<ReportDefinition> load(string id)
  {
    throw(makeError("", PRIO_SEVERE, ERR_IMPL, 1,
                    "Method load is abstract in this context, \"ReportDefinitionRepository\""));
    return nullptr;
  }

  public dyn_string getAllIds()
  {
    throw(makeError("", PRIO_SEVERE, ERR_IMPL, 1,
                    "Method getAllIds is abstract in this context, \"ReportDefinitionRepository\""));
    return makeDynString();
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
};
