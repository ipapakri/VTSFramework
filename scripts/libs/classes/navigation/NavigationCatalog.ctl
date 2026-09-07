// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/navigation/NavigationTarget"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Resolves a navigation id to a target. CNS is one implementation; projects
  without CNS can supply another catalog.
*/
class NavigationCatalog
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigationCatalog()
  {
  }

  public shared_ptr<NavigationTarget> resolve(string id)
  {
    throw(makeError("", PRIO_SEVERE, ERR_IMPL, 1, "Method resolve is abstract in this context, \"NavigationCatalog\""));
    return nullptr;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
};
