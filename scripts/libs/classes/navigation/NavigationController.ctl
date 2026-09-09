// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/navigation/NavigationCatalog"
#uses "classes/navigation/NavigationGuard"
#uses "classes/navigation/NavigationTarget"
#uses "classes/navigation/NavigationView"


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
  Resolves a target, authorizes it, then applies it to every registered view.
  Tree, map and panel are optional: a project only addView()s what it has.
*/
class NavigationController
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  public static shared_ptr<NavigationController> instance(string moduleName)
  {
    if (moduleName == "")
    {
      return nullptr;
    }

    if(!mappingHasKey(instances, moduleName))
    {
      instances[moduleName] = new NavigationController();
    }

    return instances[moduleName];
  }

  public void setNavigationCatalog(shared_ptr<NavigationCatalog> navigationCatalog)
  {
    this.navigationCatalog = navigationCatalog;
  }

  public void setGuard(shared_ptr<NavigationGuard> navigationGuard)
  {
    if (navigationGuard == nullptr)
    {
      this.navigationGuard = new NavigationGuard();
      return;
    }

    this.navigationGuard = navigationGuard;
  }

  public void addView(shared_ptr<NavigationView> navigationView)
  {
    if (navigationView == nullptr)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Ignoring null navigation view");
      return;
    }

    dynAppend(views, navigationView);
  }

  public NavigationResult navigate(string id)
  {
    DebugTN(__FILE__, __FUNCTION__, __LINE__, id);
    if (navigationCatalog == nullptr)
    {
      DebugN("Navigation catalog is not set:", id);
      return NavigationResult::NAVIGATION_EXECUTION_FAILED;
    }

    if(id == "")
    {
      id = navigationCatalog.getRoot();
    }

    return applyTarget(navigationCatalog.resolve(id), id);
  }

  public NavigationResult navigateToTarget(shared_ptr<NavigationTarget> target)
  {
    string id;
    if (target != nullptr)
      id = target.getId();

    return applyTarget(target, id);
  }

  public string getCurrentRouteId()
  {
    return currentRouteId;
  }

  public shared_ptr<NavigationTarget> getCurrentTarget()
  {
    return currentTarget;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  private NavigationController()
  {
    this.navigationGuard = new NavigationGuard();
  }

  private NavigationResult applyTarget(shared_ptr<NavigationTarget> target, string id)
  {
    if (target == nullptr)
    {
      DebugN("Navigation target not found:", id);
      return NavigationResult::NAVIGATION_ROUTE_NOT_FOUND;
    }

    if (!navigationGuard.canNavigate(target))
    {
      DebugN("Navigation access denied:", target.getId());
      return NavigationResult::NAVIGATION_ACCESS_DENIED;
    }

    bool ok = true;

    DebugTN("NAV-IN", "asked", id, "target.getId()", target.getId(),
        "currentRoute", currentRouteId);

    for (int i = 1; i <= dynlen(views); i++)
    {
      shared_ptr<NavigationView> view = views[i];

      if (!view.apply(target))
      {
        DebugN("Navigation view failed:", target.getId(), i);
        ok = false;
      }
    }

    DebugTN("NAV-OUT", "target.getId()", target.getId(), "ok", ok);

    if (!ok)
      return NavigationResult::NAVIGATION_EXECUTION_FAILED;

    currentTarget = target;
    currentRouteId = target.getId();

    return NavigationResult::NAVIGATION_OK;
  }

  private shared_ptr<NavigationCatalog> navigationCatalog;
  private shared_ptr<NavigationGuard> navigationGuard;
  private dyn_anytype views;
  private shared_ptr<NavigationTarget> currentTarget;
  private string currentRouteId;

  private static mapping instances;
};
