// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/navigation/NavigationRoute"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/
class NavigationRegistry
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigationRegistry()
  {
  }

  public bool add(shared_ptr<NavigationRoute> navigationRoute)
  {
    if(!navigationRoute)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Navigation route is null");
      return false;
    }

    string routeId = navigationRoute.getRoureId();

    if(mappingHasKey(navigationRoutes, routeId))
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Duplicate navigation route: " + routeId);
      return false;
    }

    navigationRoutes[routeId] = navigationRoute;
    return true;
  }

  public shared_ptr<NavigationRoute> find(string routeId)
  {
    if(!mappingHasKey(navigationRoutes, routeId))
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Route not in registry: " + routeId);
      return nullptr;
    }

    shared_ptr<NavigationRoute> navigationRoute = navigationRoutes[routeId];
    return navigationRoute;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private mapping navigationRoutes;
};
