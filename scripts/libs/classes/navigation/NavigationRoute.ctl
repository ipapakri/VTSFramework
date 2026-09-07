// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/navigation/commands/NavigationCommand"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/
class NavigationRoute
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigationRoute(string routeId,
                         shared_ptr<NavigationCommand> navigationCommand)
  {
    this.routeId = routeId;
    this.navigationCommand = navigationCommand;
  }

  public string getRoureId()
  {
    return this.routeId;
  }

  public bool execute()
  {
    if (!navigationCommand)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Route has no command:", routeId);
      return false;
    }

    return navigationCommand.execute();
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private string routeId;
  private shared_ptr<NavigationCommand> navigationCommand;
};
