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
#uses "classes/navigation/PanelNavigator"


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
                                string contentId)
  {
    this.panelNavigator = panelNavigator;
    this.contentId = contentId;
  }

  public bool execute()
  {
    if (!this.panelNavigator)
    {
      DebugN("NavigateToPanelCommand has no panel navigator");
      return false;
    }

    return panelNavigator.showPanel(contentId, makeDynString());
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
