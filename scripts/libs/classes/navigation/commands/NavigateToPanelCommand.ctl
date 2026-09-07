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
class NavigateToPanelCommand : NavigationCommand
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigateToPanelCommand(shared_ptr<PanelNavigator> panelNavigator,
                                string contendId)
  {
    this.panelNavigator = panelNavigator;
    this.contentId = contendId;
  }

  public bool execute()
  {
    if (!this.panelNavigator)
    {
      DebugN("ShowContentCommand has no content navigator");
      return false;
    }

    return panelNavigator.showContent(contentId,
                                      makeDynString());
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private shared_ptr<PanelNavigator> panelNavigator;
  private string contentId;
};
