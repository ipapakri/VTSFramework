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
  Optional navigation surface (tree, map, panel, ...).
  Register only the views the project has.
*/
class NavigationView
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigationView()
  {
  }

  /**
    Apply the target to this surface.
    Return true on success or intentional no-op (e.g. no location on a map view).
  */
  public bool apply(shared_ptr<NavigationTarget> target)
  {
    throw(makeError("", PRIO_SEVERE, ERR_IMPL, 1, "Method apply is abstract in this context, \"NavigationView\""));
    return false;
  }

  public bool getReady()
  {
    return this.ready;
  }

  public void setReady(bool ready)
  {
    this.ready = ready;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private bool ready;
};
