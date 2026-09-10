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
#uses "classes/navigation/NavigationListener"
#uses "classes/navigation/NavigationTarget"
#uses "classes/navigation/NavigationView"


//--------------------------------------------------------------------------------
// Variables and Constants
enum NavigationResult
{
  NAVIGATION_OK,
  NAVIGATION_ROUTE_NOT_FOUND,
  NAVIGATION_ACCESS_DENIED,
  /**
    The target was committed, but at least one view failed to display it.
  */
  NAVIGATION_EXECUTION_FAILED
};

//--------------------------------------------------------------------------------
/**
  Resolves a target, authorizes it, then applies it to every registered view.
  Tree, map and panel are optional: a project only addView()s what it has.

  This is the single entry point for navigation. Any component (an alarm row,
  a button in a process panel, a breadcrumb) navigates by id and does not need
  to know which surfaces exist.

  Interactive views pass themselves as the source of a request. The controller
  then skips that view when broadcasting, because a view that started the
  navigation already shows the target - that is what keeps a tree click from
  looping back into itself through setSelectedItem().
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

  /**
    Drops the controller registered for moduleName. Call from the navigator
    panel's Terminate: the views hold shape handles that die with the panel.
  */
  public static void release(string moduleName)
  {
    if (mappingHasKey(instances, moduleName))
    {
      mappingRemove(instances, moduleName);
    }
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

    if (indexOfView(navigationView.getViewId()) > 0)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Navigation view already registered");
      return;
    }

    dynAppend(views, navigationView);
  }

  public void removeView(shared_ptr<NavigationView> navigationView)
  {
    if (navigationView == nullptr)
      return;

    int index = indexOfView(navigationView.getViewId());

    if (index > 0)
      dynRemove(views, index);
  }

  public void addListener(shared_ptr<NavigationListener> listener)
  {
    if (listener == nullptr)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Ignoring null navigation listener");
      return;
    }

    if (indexOfListener(listener.getListenerId()) > 0)
      return;

    dynAppend(listeners, listener);
  }

  public void removeListener(shared_ptr<NavigationListener> listener)
  {
    if (listener == nullptr)
      return;

    int index = indexOfListener(listener.getListenerId());

    if (index > 0)
      dynRemove(listeners, index);
  }

  /**
    Navigates to id, or to the catalog root when id is "".
    @param source The view the request originates from, if any. It is left
                 untouched by the broadcast.
  */
  public NavigationResult navigate(string id, shared_ptr<NavigationView> source = nullptr)
  {
    if (navigationCatalog == nullptr)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Navigation catalog is not set:", id);
      return NavigationResult::NAVIGATION_EXECUTION_FAILED;
    }

    if(id == "")
    {
      id = navigationCatalog.getRootId();
    }

    return applyTarget(navigationCatalog.resolve(id), id, source, true);
  }

  public NavigationResult navigateToTarget(shared_ptr<NavigationTarget> target,
                                           shared_ptr<NavigationView> source = nullptr)
  {
    string id;
    if (target != nullptr)
      id = target.getId();

    return applyTarget(target, id, source, true);
  }

  public bool canGoBack()
  {
    return historyIndex > 1;
  }

  public bool canGoForward()
  {
    return historyIndex > 0 && historyIndex < dynlen(history);
  }

  public NavigationResult goBack()
  {
    if (!canGoBack())
      return NavigationResult::NAVIGATION_ROUTE_NOT_FOUND;

    return replayHistory(historyIndex - 1);
  }

  public NavigationResult goForward()
  {
    if (!canGoForward())
      return NavigationResult::NAVIGATION_ROUTE_NOT_FOUND;

    return replayHistory(historyIndex + 1);
  }

  public string getCurrentRouteId()
  {
    return currentRouteId;
  }

  public shared_ptr<NavigationTarget> getCurrentTarget()
  {
    return currentTarget;
  }

  /**
    Forgets views, listeners and history. The controller stays usable.
  */
  public void dispose()
  {
    dynClear(views);
    dynClear(listeners);
    dynClear(history);

    historyIndex = 0;
    currentRouteId = "";
    currentTarget = nullptr;
    navigating = false;
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

  private NavigationResult applyTarget(shared_ptr<NavigationTarget> target,
                                       string id,
                                       shared_ptr<NavigationView> source,
                                       bool recordHistory)
  {
    if (navigating)
    {
      // A view changed its own state while being updated and called back in
      // (a tree re-emitting selectionChanged from setSelectedItem). The
      // broadcast already under way is the authoritative one.
      return NavigationResult::NAVIGATION_OK;
    }

    if (target == nullptr)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Navigation target not found:", id);
      return NavigationResult::NAVIGATION_ROUTE_NOT_FOUND;
    }

    if (source != nullptr && target.getId() == currentRouteId)
    {
      // An echo from the surface that already shows this target, arriving
      // after the broadcast that caused it. A request without a source is
      // honoured instead, so callers can still force a refresh.
      return NavigationResult::NAVIGATION_OK;
    }

    if (!navigationGuard.canNavigate(target))
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Navigation access denied:", target.getId());

      // The requesting view may already show the denied target - a tree
      // selects on click, before anyone gets to veto - so push the target
      // that is actually committed back onto every view, source included.
      restoreCurrentTarget();
      return NavigationResult::NAVIGATION_ACCESS_DENIED;
    }

    bool ok = broadcast(target, source);

    // Committed even when a view failed: the views that did succeed have
    // already moved, so reporting the previous target would be a lie.
    assignPtr(currentTarget, target);
    currentRouteId = target.getId();

    if (recordHistory)
      pushHistory(currentRouteId);

    notifyListeners(target);

    if (!ok)
      return NavigationResult::NAVIGATION_EXECUTION_FAILED;

    return NavigationResult::NAVIGATION_OK;
  }

  private bool broadcast(shared_ptr<NavigationTarget> target, shared_ptr<NavigationView> source)
  {
    bool ok = true;
    int sourceId = 0;

    if (source != nullptr)
      sourceId = source.getViewId();

    navigating = true;

    for (int i = 1; i <= dynlen(views); i++)
    {
      shared_ptr<NavigationView> view = views[i];

      if (sourceId != 0 && view.matchesView(sourceId))
        continue;

      if (!view.apply(target))
      {
        DebugTN(__FILE__, __FUNCTION__, __LINE__, "Navigation view failed:", target.getId(), i);
        ok = false;
      }
    }

    navigating = false;

    return ok;
  }

  private void restoreCurrentTarget()
  {
    if (currentTarget == nullptr)
      return;

    broadcast(currentTarget, nullptr);
  }

  private NavigationResult replayHistory(int index)
  {
    if (navigationCatalog == nullptr)
      return NavigationResult::NAVIGATION_EXECUTION_FAILED;

    string id = history[index];
    NavigationResult result = applyTarget(navigationCatalog.resolve(id), id, nullptr, false);

    if (result == NavigationResult::NAVIGATION_OK ||
        result == NavigationResult::NAVIGATION_EXECUTION_FAILED)
    {
      historyIndex = index;
    }

    return result;
  }

  private void pushHistory(string id)
  {
    if (historyIndex > 0 && history[historyIndex] == id)
      return;

    // A new destination replaces whatever we could have gone forward to.
    while (dynlen(history) > historyIndex)
    {
      dynRemove(history, dynlen(history));
    }

    dynAppend(history, id);
    historyIndex = dynlen(history);
  }

  private void notifyListeners(shared_ptr<NavigationTarget> target)
  {
    for (int i = 1; i <= dynlen(listeners); i++)
    {
      shared_ptr<NavigationListener> listener = listeners[i];
      listener.onNavigated(target);
    }
  }

  private int indexOfView(int viewId)
  {
    for (int i = 1; i <= dynlen(views); i++)
    {
      shared_ptr<NavigationView> view = views[i];

      if (view.getViewId() == viewId)
        return i;
    }

    return 0;
  }

  private int indexOfListener(int listenerId)
  {
    for (int i = 1; i <= dynlen(listeners); i++)
    {
      shared_ptr<NavigationListener> listener = listeners[i];

      if (listener.getListenerId() == listenerId)
        return i;
    }

    return 0;
  }

  private shared_ptr<NavigationCatalog> navigationCatalog;
  private shared_ptr<NavigationGuard> navigationGuard;
  private dyn_anytype views;
  private dyn_anytype listeners;
  private shared_ptr<NavigationTarget> currentTarget;
  private string currentRouteId;
  private bool navigating;

  private dyn_string history;
  private int historyIndex;

  private static mapping instances;
};
