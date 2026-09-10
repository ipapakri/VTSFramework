// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  A navigation scope is one navigator: a controller, its views, and the set of
  modules those views drive. It is identified by the module name of the panel
  that owns it.

  The navigator panel attaches every module it drives to its own scope:

    navigatorScope = myModuleName();
    NavigationScope::attachModule(navigatorScope, MAP_MODULE_NAME);
    NavigationScope::attachModule(navigatorScope, MAIN_MODULE_NAME);

  Any script running in one of those modules - a sub-panel, a map symbol, a
  button in a process panel - then finds the navigator without being told
  which one it belongs to:

    NavigationScope::current()

  which is why nothing needs a $NavigatorName parameter threaded through it.
*/
class NavigationScope
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  /**
    Declares that everything running in moduleName belongs to scopeId.
  */
  public static void attachModule(string scopeId, string moduleName)
  {
    if (scopeId == "" || moduleName == "")
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Ignoring empty scope or module", scopeId, moduleName);
      return;
    }

    modules[moduleName] = scopeId;
  }

  public static void detachModule(string moduleName)
  {
    if (mappingHasKey(modules, moduleName))
    {
      mappingRemove(modules, moduleName);
    }
  }

  /**
    Scope a module belongs to. An unattached name is returned unchanged, so
    the owning panel resolves to its own module name without registering
    itself.
  */
  public static string resolve(string moduleName)
  {
    if (mappingHasKey(modules, moduleName))
      return modules[moduleName];

    return moduleName;
  }

  /**
    Scope of the module the calling script runs in.
  */
  public static string current()
  {
    return resolve(myModuleName());
  }

  /**
    Forgets every module attached to scopeId. Call from the navigator panel's
    Terminate, after releasing the controller and the views.
  */
  public static void release(string scopeId)
  {
    dyn_anytype keys = mappingKeys(modules);

    for (int i = 1; i <= dynlen(keys); i++)
    {
      string moduleName = (string)keys[i];

      if (modules[moduleName] == scopeId)
        mappingRemove(modules, moduleName);
    }
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private static mapping modules;
};
