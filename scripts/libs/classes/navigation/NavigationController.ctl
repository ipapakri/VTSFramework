// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/navigation/NavigationRegistry"


//--------------------------------------------------------------------------------
// Variables and Constants
enum NavigationResult
{
  NAVIGATION_OK,
  NAVIGATION_ROUTE_NOT_FOUND,
  NAVIGATION_ACCESS_DENIED,
  NAVIGATION_EXECUTION_FAILED
};

//--------------------------------------------------------------------------------
/**
*/
class NavigationController
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigationController(shared_ptr<NavigationRegistry> navigationRegistry)
  {
    this.navigationRegistry = navigationRegistry;
  }

  public NavigationResult navigate(string routeId)
  {
    shared_ptr<NavigationRoute> navigationRoute = navigationRegistry.find(routeId);

    if (!navigationRoute)
    {
      DebugN("Navigation route not found:", routeId);
      return NAVIGATION_ROUTE_NOT_FOUND;
    }

    /*if (!_access.canNavigate(routeId))
    {
      DebugN("Navigation access denied:", routeId);
      return NAVIGATION_ACCESS_DENIED;
    }*/

    if (!navigationRoute.execute())
    {
      DebugN("Navigation execution failed:", routeId);
      return NAVIGATION_EXECUTION_FAILED;
    }

    currentRouteId = routeId;
    return NAVIGATION_OK;
  }

  public string getCurrentRouteId()
  {
    return _currentRouteId;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private shared_ptr<NavigationRegistry> navigationRegistry;
  private string currentRouteId;
};
