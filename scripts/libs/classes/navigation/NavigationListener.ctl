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
  Observer of the current navigation target, for components that react to
  navigation without displaying it: breadcrumbs, window titles, alarm filters.
  Register with NavigationController::addListener().
*/
class NavigationListener
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigationListener()
  {
  }

  /**
    Called after a target has been committed and pushed to the views.
    Default is a no-op.
  */
  public void onNavigated(shared_ptr<NavigationTarget> target)
  {
  }

  /**
    Process-wide unique handle, used by removeListener().
  */
  public int getListenerId()
  {
    // Assigned lazily rather than in the constructor so that subclasses keep
    // an identity even if they never chain to this base constructor.
    if (listenerId == 0)
    {
      nextListenerId++;
      listenerId = nextListenerId;
    }

    return listenerId;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private int listenerId;

  private static int nextListenerId;
};
